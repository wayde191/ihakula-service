# encoding: utf-8

require 'json'
require 'digest/md5'
require 'perfect-random-number-generator'

require_relative '../../app/database/order_db'
require_relative '../../app/stores/jpush_store'
require_relative '../../app/log_formatter'
require_relative '../../app/log_wrapper'
require_relative '../../app/exceptions/ihakula_service_error'
require_relative '../../app/api/status_codes'

class OrderStore

  def initialize(app_settings)
    @settings = app_settings
    @ihakula_push_store = IhakulaPushStore.new(app_settings)
    @logger = LogWrapper.new(app_settings, LogFormatter.new)

    @MAGIC = []
    29.downto(0) {|i| @MAGIC << 839712541[i]}
  end

  def create_order(parameters)
    begin
      count = Ih_order.count
      order_number = get_order_number_by_id(count)
      Ih_order.create(
          order_number: order_number,
          user_id: parameters[:user_id],
          cart: parameters[:cart],
          sale_price: parameters[:sale_price],
          real_price: parameters[:real_price],
          state: ORDER_CREATED,
          start_date: get_current_time
      )

    rescue StandardError => ex
      write_exception_details_to_log(ex, 'create_order', 'paras')
      raise IhakulaServiceError, ex.message
    end
  end

  def get_user_orders(user_id)
    begin
      Ih_order.where(user_id: user_id)
    rescue StandardError => ex
      write_exception_details_to_log(ex, 'get_user_orders', 'paras')
      raise IhakulaServiceError, ex.message
    end
  end

  def accept_order(parameters)
    begin
      order = Ih_order.find_by(id: parameters[:id], order_number: parameters[:order_number])
      if order.nil? then
        raise IhakulaServiceError, 'Order not exist.'
      elsif order[:state].equal? ORDER_CONFIRMED
        raise IhakulaServiceError, 'Order confirmed already.'
      else
        order[:state] = ORDER_CONFIRMED
        order[:confirm_date] = get_current_time
        order.save
      end
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  private

  def get_order_number_by_id(order_id)
    order = 0
    0.upto(@MAGIC.length - 1)  {|i| order = order << 1 | (order_id[i] ^ @MAGIC[i]) }
    order
  end

  def generate_coupon(activity_id, index)
    created_time = get_current_time;
    Digest::MD5.hexdigest("NorthernHemisphere:#{activity_id}:#{created_time}:#{index}")
  end

  def get_current_time
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

  def get_empty_time
    '0000-00-00 00:00:00'
  end

  def write_exception_details_to_log(exception, request, request_parameters)
    puts exception.message
    @logger.error_details(exception.message, request, request_parameters, 'IhakulaStore')
  end
end
