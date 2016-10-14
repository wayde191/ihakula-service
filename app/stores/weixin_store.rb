require 'json'

require_relative '../../app/exceptions/ihakula_service_error'

class WeixinStore

  def initialize(session, app_settings, http_client)
    @session = session
    @http_client = http_client
    @settings = app_settings
    @logger = LogWrapper.new(app_settings, LogFormatter.new)
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

  def validate_request
    unless request_come_from_ihakula
      redirect '/'
    end
  end

  def dispatch_request
    @access_token = get_access_token
    @request_xml = @params[:request_xml]
    @request_json = JSON.parse(Hash.from_xml(@request_xml).to_json)

    type = @request_json['xml']['MsgType']
    case type
      when 'event'
        # msg_type_event_dispatcher
      when 'text'
        msg_type_text_dispatcher
    end
  end

  def msg_type_text_dispatcher
    command_hash = get_command_hash

    case command_hash[:key]
      when 'BBQ' || 'bbq' || '0'
        show_guide_service_list
        # show_welcome_message
      # when '1' #当前优惠活动
      #   show_all_activities
      # when '2' #参加活动
      #   show_activity_link_page(command_hash[:value])
      # when '3' #我的优惠券
      #   show_my_coupons
      # when '4' #生成二维码
      #   create_qrcode(command_hash[:value])
      # when '5' #最新消息
      #   show_latest_message
      else
        show_guide_service_list
    end
  end


  def request_come_from_ihakula
    @params[:ihakula_request] == 'ihakula_northern_hemisphere'
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

  def get_command_hash
    @request_message = @request_json['xml']['Content']
    command_hash = {:key=>@request_message}

    if @request_message.length > 1 then
      @request_message.sub! '：',':'

      if /^2:/ =~ @request_message then
        command_hash = {:key=>'2', :value=>$'}
      elsif /^4:/ =~ @request_message then
        command_hash = {:key=>'4', :value=>$'}
      end
    end

    command_hash
  end

  def get_current_time
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

  def show_guide_service_list
    @message = "呃...不大明白，或者您的问题真的难倒我了，
                要不您换个问法再试试，或许小北和球球就能明白啦！
                您也可以输入序号使用以下服务：\n
                [0]关于《BBQ北伴球》
                [1]当前优惠活动
                [2]'2:'+活动序号参加活动（如2:1）
                [3]我的优惠券
                [4]'4:'+优惠券序号生成二维码(如4:1)\n"
    @message = @message.gsub(/ /, '')
    get_response_xml_message_by_type('text')
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

  def show_welcome_message
    about_us_json = get_template_about_us_item_json
    @article_items_arr = [about_us_json]
    get_response_xml_message_by_type('article')
  end

  def get_template_about_us_item_json
    {
        title: '关于我们：BBQ北伴球',
        description: '您好，我们是小北和球球！很高兴能为您服务 ：) 。 为您提供优质的服务，是我们毕生的追求！',
        pic_url: 'http://www.ihakula.com/bbq/wp-content/uploads/2015/07/place_holder_360200.png',
        url: 'http://www.ihakula.com/bbq/?page_id=4'
    }
  end

end
