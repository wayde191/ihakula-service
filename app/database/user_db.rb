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