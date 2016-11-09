# encoding: utf-8
require 'json'

require_relative '../../app/stores/base/weixin'
require_relative '../../app/exceptions/ihakula_service_error'

class WeixinZyStore < Weixin

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

  def msg_type_text_dispatcher
    command_hash = get_command_hash

    case command_hash[:key]
      when 'ZY' || 0 || '0' || 'zy'
        show_welcome_message
      when '1'
        show_latest_message
      when '2'
        show_delay_message
      when '3'
        show_delay_calculator
      when '4'
        show_lawyer_info
      when '5'
        show_no1_info
      when '6'
        show_contact_info
      when '?' #使用说明
        show_guide_service_list
      else
        show_guide_service_list
    end
  end

  def show_guide_service_list
    @message = "呃...不大明白，要不您换个问法再试试，或许小冶就能明白了！
                您也可以输入序号使用以下服务：\n
                [0]关于
                [1]最新小区消息
                [2]娃哈哈桶装水：15307191393
                [3]延期赔偿计算器
                [4]钟律师联系方式
                [5]售楼部联系方式
                [6]业主沟通群
                [?]使用说明\n\n
                常用沟通渠道：
                QQ群：126679807
                微信：中冶创业苑业主群
                公从号：WH中冶创业苑的
                "
    @message = @message.gsub(/ /, '')
    get_response_xml_message_by_type('text')
  end

  def show_welcome_message
    about_us_json = get_template_about_us_item_json
    @article_items_arr = [about_us_json]
    get_response_xml_message_by_type('article')
  end

  def get_template_about_us_item_json
    {
        title: '中冶创业苑',
        description: '中冶创业苑微信公众号，为您收集周边生活所有信息，记录幸福小区生活每一天。',
        pic_url: 'http://www.ihakula.com:9000/no1/wp-content/uploads/2016/11/中冶.jpg',
        url: 'http://www.ihakula.com/bing.html#/page/detail/217'
    }
  end

end