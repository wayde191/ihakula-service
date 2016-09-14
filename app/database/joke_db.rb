require 'active_record'
require 'mysql2'

#Connetction
class JokeDatabaseConnection < ActiveRecord::Base
  self.abstract_class = true
end

JokeDatabaseConnection.establish_connection(
    adapter:  'mysql2',
    host:     'localhost',
    database: 'ihakula_joke',
    username: 'root',
    password: 'Wayde191!'
)

#Model
class Joke < JokeDatabaseConnection
  self.table_name = 'joke'
  self.inheritance_column = :_type_disabled
end

class JokeContent < JokeDatabaseConnection
  self.table_name = 'joke_content'
  self.inheritance_column = :_type_disabled
end