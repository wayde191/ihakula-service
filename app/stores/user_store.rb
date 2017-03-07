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
      return wx_session unless wx_session['errcode'].nil?

      # use session_key and open_id create token
      # if user exist, update user info
      # if user not exist, insert user info
      @logger.log_info('===========')
      @logger.log_info(wx_session['session_key'])
      @logger.log_info(wx_session['openid'])
      decrypted_data = decrypt(paras[:app_id], wx_session['session_key'], paras[:iv], paras[:encrypted_data])
      decrypted_data
    rescue StandardError, IhakulaServiceError => ex
      @logger.log_info('EXCEPTION')
      raise IhakulaServiceError, ex.message
    end
  end

  private
  def decrypt(app_id, session_key, iv, encrypted_data)
    wx_crypt = WXBizDataCrypt.new(app_id, session_key)
    wx_crypt.decrypt(encrypted_data, iv)
  end

  def get_wx_key(code, app_id)
    wx_lp = get_little_program app_id
    app_id = wx_lp[:app_id]
    app_secret = wx_lp[:app_secret]
    url = "https://api.weixin.qq.com/sns/jscode2session?appid=#{app_id}&secret=#{app_secret}&js_code=#{code}&grant_type=authorization_code"

    response = @http_client.get(url).body
    @logger.log_info(response)
    JSON.parse(response.to_json)
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
