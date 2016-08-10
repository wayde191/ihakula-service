require 'active_record'
require 'mysql2'

#Connetction
class OrderDatabaseConnection < ActiveRecord::Base
  self.abstract_class = true
end

OrderDatabaseConnection.establish_connection(
    adapter:  'mysql2',
    host:     'localhost',
    database: 'ihakula_tea',
    username: 'root',
    password: 'Hakula567'
)

#Model
class Ih_order < OrderDatabaseConnection
  self.table_name = 'ih_order'
  self.inheritance_column = :_type_disabled
end