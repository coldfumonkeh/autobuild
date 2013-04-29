class Clients

  include DataMapper::Resource
  
  property :id, String, key: true, unique_index: true, required: true
  property :username, String, required: true
  property :password, String, required: true
  property :created_at, DateTime
  property :updated_at, DateTime
  
end