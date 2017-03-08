require_relative '../../app/database/user_db'
require_relative '../../app/exceptions/ihakula_service_error'
require_relative '../../app/stores/base/wx_biz_data_crypt'

require 'base64'


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

      decrypted_data = decrypt(paras[:app_id], wx_session['session_key'], paras[:iv], paras[:encrypted_data])
      user_id = update_user_info decrypted_data
      get_token(wx_session['session_key'], wx_session['openid'], user_id, paras[:app_id])
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  private
  def get_token(session_key, open_id, user_id, app_id)
    token = Base64.strict_encode64("#{session_key}#{user_id}")
    Wx_token.create(
         token: token,
         open_id: open_id,
         session_key: session_key,
         wx_app_id: app_id,
         wx_user_id: user_id,
         valid_time: 30.days.from_now
    )
    token
  end

  def update_user_info(user_info)
    union_id = Base64.strict_encode64("#{user_info['openId']}#{user_info['watermark']['appid']}")
    user = Wx_user.find_by(union_id: union_id)

    if user.nil? then
      Wx_user.create(
          union_id: union_id,
          nickName: user_info['nickName'],
          gender: user_info['gender'],
          city: user_info['city'],
          province: user_info['province'],
          country: user_info['country'],
          avatarUrl: user_info['avatarUrl'],
          create_time: get_current_time,
          activity_time: get_current_time
      )
    else
      user[:nickName] = user_info['nickName']
      user[:gender] = user_info['gender']
      user[:city] = user_info['city']
      user[:province] = user_info['province']
      user[:country] = user_info['country']
      user[:avatarUrl] = user_info['avatarUrl']
      user[:activity_time] = get_current_time
      user.save
    end

    union_id
  end

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

  def get_empty_time
    '0000-00-00 00:00:00'
  end
end