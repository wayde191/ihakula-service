# encoding: utf-8
require 'json'

require_relative '../../../app/exceptions/ihakula_service_error'

class Weixin

  def initialize(session, app_settings, http_client)
    @session = session
    @http_client = http_client
    @settings = app_settings
    @logger = LogWrapper.new(app_settings, LogFormatter.new)

    @params = []
    @access_token = nil
    @request_xml = nil
    @request_json = nil
    @request_message = nil
    @message = nil
    @article_items_arr = []
  end

  def event_handler(params)
    begin
      @params = params
      validate_request
      dispatch_request
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  private

  def msg_type_event_dispatcher
    event = @request_json['xml']['Event']
    case event
      when 'subscribe'
        show_guide_service_list
      when 'SCAN'
        show_guide_service_list
      else
        show_guide_service_list
    end
  end

  def dispatch_request
    @access_token = get_access_token
    @request_xml = @params[:request_xml]
    @request_json = JSON.parse(Hash.from_xml(@request_xml).to_json)

    type = @request_json['xml']['MsgType']
    case type
      when 'event'
        msg_type_event_dispatcher
      when 'text'
        msg_type_text_dispatcher
    end
  end

  def get_access_token
    token = @session[:token]
    if token.nil? then
      token = refresh_access_token
    else
      url = "https://api.weixin.qq.com/cgi-bin/getcallbackip?access_token=#{token}"
      body_json = JSON.parse(@http_client.get(url).body.to_json)
      if body_json['ip_list'].nil?
        token = refresh_access_token
      end
    end

    token
  end

  def refresh_access_token
    app_id = 'wx32c089c7ce016ab7'
    app_secret = 'b1c0c431cbcf9f35ba2b771b426eb7b5'
    url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{app_id}&secret=#{app_secret}"

    body_json = JSON.parse(@http_client.get(url).body.to_json)

    @session[:token] = body_json['access_token']
    @session[:token]
  end

  def validate_request
    unless request_come_from_ihakula
      redirect 'http://www.ihakula.com'
    end
  end

  def request_come_from_ihakula
    @params[:ihakula_request] == 'ihakula_northern_hemisphere'
  end

  def get_response_xml_message_by_type(message_type)
    case message_type
      when 'text'
        formatted_text_response_xml_message
      when 'article'
        formatted_article_response_xml_message
    end
  end

  def formatted_text_response_xml_message
    time = Time.now().nsec
    "
      <xml>
        <ToUserName><![CDATA[#{@request_json['xml']['FromUserName']}]]></ToUserName>
        <FromUserName><![CDATA[#{@request_json['xml']['ToUserName']}]]></FromUserName>
        <CreateTime>#{time}</CreateTime>
        <MsgType><![CDATA[text]]></MsgType>
        <Content><![CDATA[#{@message}]]></Content>
      </xml>
    "
  end

  def formatted_article_response_xml_message
    time = Time.now().nsec
    article_count = @article_items_arr.count
    article_items = get_article_items_xml
    "
      <xml>
        <ToUserName><![CDATA[#{@request_json['xml']['FromUserName']}]]></ToUserName>
        <FromUserName><![CDATA[#{@request_json['xml']['ToUserName']}]]></FromUserName>
        <CreateTime>#{time}</CreateTime>
        <MsgType><![CDATA[news]]></MsgType>
        <ArticleCount>#{article_count}</ArticleCount>
        <Articles>#{article_items}</Articles>
      </xml>
    "
  end

  def get_article_items_xml
    items_parsed_xml = '';
    @article_items_arr.each do |item|
      items_parsed_xml += "
      <item>
        <Title><![CDATA[#{item[:title]}]]></Title>
        <Description><![CDATA[#{item[:description]}]]></Description>
        <PicUrl><![CDATA[#{item[:pic_url]}]]></PicUrl>
        <Url><![CDATA[#{item[:url]}]]></Url>
      </item>
    "
    end
    items_parsed_xml
  end

  def show_guide_service_list
    @message = "呃...不大明白，要不您换个问法再试试，或许小滨就能明白了！
                您也可以输入序号使用以下服务：\n
                [0]关于
                [1]最新小区消息
                [2]交房倒计时
                [3]延期赔偿计算器
                [4]钟律师联系方式
                [5]售楼部联系方式
                [6]业主沟通群
                [?]使用说明\n\n
                常用沟通渠道：
                QQ群：248177761
                微信：滨湖壹家人
                公从号：滨湖社区NO1
                "
    @message = @message.gsub(/ /, '')
    get_response_xml_message_by_type('text')
  end

  def get_command_hash
    @request_message = @request_json['xml']['Content']
    command_hash = {:key=>@request_message}
    command_hash
  end

  def msg_type_text_dispatcher
    command_hash = get_command_hash

    case command_hash[:key]
      when '?'
        show_guide_service_list
      else
        show_guide_service_list
    end
  end
end