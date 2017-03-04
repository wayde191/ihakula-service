require_relative '../../app/database/user_db'
require_relative '../../app/exceptions/ihakula_service_error'
require_relative '../../app/stores/base/wx_biz_data_crypt'

class UserStore

  def initialize(app_settings, http_client)
    @settings = app_settings
    @http_client = http_client
    @logger = LogWrapper.new(app_settings, LogFormatter.new)
  end

  def get_contact(user_id)
    begin
      Ih_contact.where(user_id: user_id)
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  def create_contact(parameters)
    begin
      Ih_contact.create(
          name: parameters[:name],
          phone: parameters[:phone],
          address: parameters[:address],
          user_id: parameters[:user_id],
          default: 'no',
          date: get_current_time
      )
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  def update_contact(parameters)
    begin
      contact = Ih_contact.find_by(id: parameters[:id], user_id: parameters[:user_id])
      if contact.nil? then
        raise IhakulaServiceError, 'Contact not exist.'
      else
        contact[:name] = parameters[:name]
        contact[:phone] = parameters[:phone]
        contact[:address] = parameters[:address]
        contact[:default] = parameters[:default]
        contact[:date] = get_current_time
        contact.save
      end
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  # ==========================================================
  # Wechat little program
  def get_wx_token(paras)
    begin
      wx_session = get_wx_key(paras[:code], paras[:app_id])
      wx_session[:open_id]
      wx_session[:session_key]
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  private
  def get_wx_key(code, app_id)
    wx_lp = get_little_program app_id
    app_id = wx_lp[:app_id]
    app_secret = wx_lp[:app_secret]
    url = "https://api.weixin.qq.com/sns/jscode2session?appid=#{app_id}&secret=#{app_secret}&js_code=#{code}&grant_type=authorization_code"

    JSON.parse(@http_client.get(url).body.to_json)
  end

  def get_little_program(app_id)
    begin
      Wx_app.find_by(app_id: app_id)
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  def get_current_time
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end
end
