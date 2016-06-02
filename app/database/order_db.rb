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
    password: 'Wayde191!'
)

#Model
class Ih_account_field < OrderDatabaseConnection
  self.table_name = 'ih_account_field'
  self.inheritance_column = :_type_disabled
end