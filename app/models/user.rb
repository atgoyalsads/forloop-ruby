class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :fname, type: String
  field :lname, type: String
  field :email, type: String
end
