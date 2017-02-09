require 'active_record'
require 'mysql2'

#Connetction
class OrderDatabaseConnection < ActiveRecord::Base
  self.abstract_class = true
end

OrderDatabaseConnection.establish_connection(
    adapter:  'mysql2',
    host:     ENV['DB_PORT_3306_TCP_ADDR'],
    database: 'ihakula_tea',
    username: 'root',
    password: 'Wayde191!'
)

#Model
class Ih_order < OrderDatabaseConnection
  self.table_name = 'ih_order'
  self.inheritance_column = :_type_disabled
end