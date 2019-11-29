class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :fname, type: String
  field :lname, type: String
  field :email, type: String
  # For bcrypt-ruby Begin======================
  field :password_hash, type: String
  field :password_salt, type: String

  attr_accessor :password

  before_save :encrypt_password

  def self.authenticate(email, password)
    begin
      user = find_by(email: email)
      if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
        user
      else
        nil
      end
    rescue Exception => e
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  # For bcrypt-ruby End----------------------

  # Model Validation Begin===================
  validates :fname, :email, presence: true
  validates :email, uniqueness: true
  # Model Validation End----------------------


end
