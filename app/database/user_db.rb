require 'active_record'
require 'mysql2'

#Connetction
class UserDatabaseConnection < ActiveRecord::Base
  self.abstract_class = true
end

UserDatabaseConnection.establish_connection(
    adapter:  'mysql2',
    host:     ENV['DB_PORT_3306_TCP_ADDR'],
    database: 'ihakula_sso',
    username: 'root',
    password: 'Wayde191!'
)

#Model
class Ih_contact < UserDatabaseConnection
  self.table_name = 'ih_contact'
end


class WeChatDatabaseConnection < ActiveRecord::Base
  self.abstract_class = true
end

WeChatDatabaseConnection.establish_connection(
    adapter:  'mysql2',
    host:     ENV['DB_PORT_3306_TCP_ADDR'],
    database: 'ihakula_wechat',
    username: 'root',
    password: 'Wayde191!'
)

#Model
class Wx_user < WeChatDatabaseConnection
  self.table_name = 'wx_user'
end

class Wx_app < WeChatDatabaseConnection
  self.table_name = 'wx_app'
end

class Wx_token < WeChatDatabaseConnection
  self.table_name = 'wx_token'
end

class Ih_garden < WeChatDatabaseConnection
  self.table_name = 'ih_garden'
end

class Ih_house < WeChatDatabaseConnection
  self.table_name = 'ih_house'
end

class Ih_leasehold < WeChatDatabaseConnection
  self.table_name = 'ih_leasehold'
end

class Ih_facility < WeChatDatabaseConnection
  self.table_name = 'ih_facility'
end

class Ih_facility_item < WeChatDatabaseConnection
  self.table_name = 'ih_facility_item'
end