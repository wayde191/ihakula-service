require 'active_record'
require 'mysql2'

#Connetction
class FundDatabaseConnection < ActiveRecord::Base
  self.abstract_class = true
end

FundDatabaseConnection.establish_connection(
    adapter:  'mysql2',
    host:     ENV['DB_PORT_3306_TCP_ADDR'],
    database: 'ihakula_fund',
    username: 'root',
    password: 'Wayde191!'
)

#Model
class Fund < FundDatabaseConnection
  self.table_name = 'fund'
  self.inheritance_column = :_type_disabled
end