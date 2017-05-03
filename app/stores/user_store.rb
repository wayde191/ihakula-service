require_relative '../../app/database/user_db'
require_relative '../../app/exceptions/ihakula_service_error'
require_relative '../../app/stores/base/wx_biz_data_crypt'
require_relative '../../app/api/status_codes'

require 'base64'
include StatusCodes

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

  def get_token_record(token)
    begin
      Wx_token.find_by(token: token)
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  # ==========================================================
  # Wechat little program
  def get_user_asset(user_id)
    begin
      user = Wx_user.find_by(id: user_id)
      leaseholds = Ih_leasehold
                       .where('end_time > ?', get_current_time)
                       .where(guest_id: user_id)
      my_house = (Ih_house.where(host_id: user_id) if user['role'].eql? WX_HOST) || []

      contracts = []
      leaseholds.each do |leasehold|
        house = Ih_house.find_by(id: leasehold['house_id'])
        garden = Ih_garden.find_by(id: house['garden_id'])
        host = Wx_user.find_by(id: house['host_id'])

        contracts << {
            house: get_house_detail_with_security_info(house, garden, host),
            payment: Ih_payment.find_by(leasehold_id: leasehold['id']),
            startTime: leasehold['start_time'],
            endTime: leasehold['end_time'],
            deposit: leasehold['deposit'],
            price: leasehold['price']
        }
      end

      my_house_list = []
      my_house.each do |house|
        garden = Ih_garden.find_by(id: house['garden_id'])
        host = Wx_user.find_by(id: house['host_id'])
        my_house_list << get_house_detail_with_security_info(house, garden, host)
      end

      {
          my_house: my_house_list,
          contracts: contracts
      }

    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  def get_house_detail(house_id)
    begin
      house = Ih_house.find_by(id: house_id)
      garden = Ih_garden.find_by(id: house['garden_id'])
      host = Wx_user.find_by(id: house['host_id'])

      {
          name: house['name'],
          layout: house['layout'],
          orientation: house['orientation'],
          area: house['area'],
          floor: house['floor'],
          avatar: house['avatar'],
          facilities: get_facilities(house['facilities']),
          garden: garden,
          host: {
              nickName: host['nickName'],
              avatarUrl: host['avatarUrl']
          }
      }
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  def rent_house(user_id, invite_code, house_id)
    begin
      house = Ih_house.find_by(id: house_id)
      return {message: 'invite code error', error: INVITE_CODE_ERROR} if house['invite_code'] != invite_code
      return {message: 'house not available', error: HOUSE_NOT_AVAILABLE} if house['status'] != HOUSE_AVAILABLE

      Ih_leasehold.create(
          house_id: house['id'],
          host_id: house['host_id'],
          guest_id: user_id,
          start_time: get_current_time,
          end_time: 365.days.from_now,
      )

      house[:status] = HOUSE_NOT_AVAILABLE
      house.save
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  def get_wx_house
    begin
      house_list = []
      houses = Ih_house.all
      houses.each do |house|
        house_list << {
            id: house['id'],
            name: house['name'],
            avatar: house['avatar']
        }
      end
      house_list
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  def fill_user_info(phone, user_id)
    begin
      user = Wx_user.find_by(id: user_id)
      user[:phone] = phone
      user.save
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  def get_wx_token(paras)
    begin
      wx_session = get_wx_key(paras[:code], paras[:app_id])
      return wx_session unless wx_session['errcode'].nil?

      decrypted_data = decrypt(paras[:app_id], wx_session['session_key'], paras[:iv], paras[:encrypted_data])
      @logger.log_info('========')
      @logger.log_info(decrypted_data)
      user_id = update_user_info decrypted_data
      @logger.log_info('update_user_info done! ========')
      {
          token: get_token(wx_session['session_key'], wx_session['openid'], user_id, paras[:app_id])
      }
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  private
  def get_house_detail_with_security_info(house, garden, host)
    {
        name: house['name'],
        layout: house['layout'],
        orientation: house['orientation'],
        area: house['area'],
        floor: house['floor'],
        avatar: house['avatar'],
        waterCode: house['water_code'],
        elecCoce: house['elec_code'],
        gasCode: house['gas_code'],
        facilities: get_facilities(house['facilities']),
        garden: garden,
        host: {
            nickName: host['nickName'],
            avatarUrl: host['avatarUrl'],
            phone: host['phone']
        }
    }
  end

  def get_facilities(facilities)
    facility_id_list = facilities.split ','
    facility_arr = []
    facility_id_list.each do |facility_id|
      facility_arr << Ih_facility.find_by(id: facility_id)
    end
    facility_arr
  end

  def get_token(session_key, open_id, user_id, app_id)
    token = Base64.strict_encode64("#{session_key}#{user_id}")
    Wx_token.create(
         token: token,
         open_id: open_id,
         session_key: session_key,
         valid_time: 30.days.from_now,
         app_id: app_id,
         user_id: user_id
    )
    token
  end

  def update_user_info(user_info)
    union_id = Base64.strict_encode64("#{user_info['openId']}#{user_info['watermark']['appid']}")
    user = Wx_user.find_by(union_id: union_id)

    if user.nil? then
      user = Wx_user.create(
          union_id: union_id,
          nickName: user_info['nickName'],
          gender: user_info['gender'],
          city: user_info['city'],
          province: user_info['province'],
          country: user_info['country'],
          avatarUrl: user_info['avatarUrl'],
          create_time: get_current_time,
          activity_time: get_current_time,
          role: 0
      )

      @http_client.post("#{@settings.bbs_service}/user/create", {
          loginname: user_info['nickName'],
          password: 'sunzhongmou.com',
          email: "#{user_info['nickName']}@qq.com",
          avatarUrl: user_info['avatarUrl']
      })

      @logger.log_info('create user --------')

    else
      user[:nickName] = user_info['nickName']
      user[:gender] = user_info['gender']
      user[:city] = user_info['city']
      user[:province] = user_info['province']
      user[:country] = user_info['country']
      user[:avatarUrl] = user_info['avatarUrl']
      user[:activity_time] = get_current_time
      user.save

      @logger.log_info('update user --------')

    end

    user[:id]
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