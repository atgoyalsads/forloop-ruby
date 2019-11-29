class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :fname, type: String
  field :lname, type: String
  field :email, type: String

  validates :fname, :email, presence: true
  validates :email, uniqueness: true
  
end
