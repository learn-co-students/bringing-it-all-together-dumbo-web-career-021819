require 'pry'
class Dog
 
 attr_accessor :name, :breed, :id
	def initialize(args)
		@name = args[:name]
		@id = args[:id]
		@breed = args[:breed]
	end


  def self.create_table
  	sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
   end
#########################
   def self.drop_table
   	sql = <<-SQL
   	DROP TABLE IF EXISTS dogs
   	SQL
   	DB[:conn].execute(sql)
   end
#######################
def save
	dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', self.name, self.breed)

	if dog.empty?
	  sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
      SQL
    result = DB[:conn].execute(sql, self.name, self.breed)
    self.update_object_from_db
    end
    end
####################
    def update_object_from_db
    select_and_create = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', self.name, self.breed)[0]
    self.id = select_and_create[0]
    self.name = select_and_create[1]
    self.breed = select_and_create[2]
    self
end
########################
def self.new_from_db(row)
	Dog.new(id: row[0],name: row[1], breed: row[2])
end
######################
def self.create(args)
	dog = Dog.new(args)
	dog.save
end
###################
def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    result = DB[:conn].execute(sql,id)
    Dog.new_from_db(result[0])
	end
#####################


def self.find_or_create_by(args)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", args[:name], args[:breed])
    if !dog.empty?
      dog_data = dog[0]
    
      dog = Dog.new(id: dog_data[0],name: dog_data[1],breed: dog_data[2])

    else
      dog = self.create(args)
    end
    dog
  end 

  ###################

def self.find_by_name(args)

sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
     
    result = DB[:conn].execute(sql,args)
if !result.empty?
    Dog.new_from_db(result[0])
else
	result.update
end
end

def update
self.save
end





	

end