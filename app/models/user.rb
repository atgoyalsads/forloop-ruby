class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :fname, type: String
  field :lname, type: String
  field :email, type: String
  field :displayName, type: String
  field :image, type: String
  field :zipcode, type: String
  field :countryCode, type: String
  field :contact, type: String
  field :dob, type: Date
  field :gender, type: String
  field :linkBlogger, type: String
  field :linkLinkedin, type: String
  field :linkInstagram, type: String
  field :linkPinterest, type: String
  field :description, type: String
  field :certificates, type: Array, default: []
  field :pricePerHour, type: Float
  field :selectedRole, type: String
  field :proDataStatus, type: Hash
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
    self.proDataStatus = {displayName: false, details: false, links: false, price: false, subcategories: false}
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  # For bcrypt-ruby End----------------------

  # Model Validation Begin===================
  validates :email, presence: true
  validates :email, uniqueness: true
  validates_presence_of :password, :on => :create
  # Model Validation End----------------------

  # associations
  has_many :subcategory_users, dependent: :destroy
  has_many :sessions, dependent: :destroy

  def id
    self._id.as_json["$oid"]
  end

  def skills
    Subcategory.where(:_id.in => self.subcategory_users.pluck(:subcategory_id)).paginate(page: 1, per_page: 3).pluck(:title)
  end

end
