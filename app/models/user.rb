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
  field :certificates, type: Array
  field :pricePerHour, type: Float
  field :selectedRole, type: String
  field :proDataStatus, type: Hash
  field :stripeCustomerId, type: String
  field :skillSet, type: Array

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

  has_many :dialedCalls, class_name: "CallHistory", inverse_of: :dialer, dependent: :destroy
  has_many :receivedCalls, class_name: "CallHistory", inverse_of: :receiver, dependent: :destroy

  has_many :rating_questions, dependent: :destroy
  has_many :received_rating_questions, class_name: "RatingQuestion", inverse_of: :receiver, dependent: :destroy

  has_many :favourites, dependent: :destroy
  has_many :in_favourites, class_name: "Favourite", inverse_of: :favouriteUser, dependent: :destroy

  def id
    self._id.as_json["$oid"]
  end

  def skills
    # Subcategory.where(:_id.in => self.subcategory_users.pluck(:subcategory_id)).paginate(page: 1, per_page: 3).pluck(:title)
    self.skillSet.to_a.first(3).map { |sks| sks["subcategoryTitle"] }
  end

  def allSkills
    self.skillSet.to_a.map { |sks| sks["subcategoryTitle"] }
  end

  def skillsJson
    self.skillSet.to_a.map { |sks| {title: sks["subcategoryTitle"], id: sks["subcategoryId"].to_s }}
  end

  def callHistories
    CallHistory.any_of({:dialerUserId => self._id}, {:receiverUserId => self._id})
  end

  def favouriteProfiles
    User.where(:_id.in=>self.favourites.pluck(:favouriteUserId))
  end

  def callsDataHome
    data = CallHistory.where(receiverUserId: self._id).pluck(:callRating, :askedQuestions)
    allCallQuestionsRatings = []
    allCallRatings = []
    data.map { |dt| 
      if dt[0].to_f>0
        callQuRatings = dt[1].to_a.map { |rq| rq["rating"].to_f}
        avgCallRating = ((dt[0].to_f+callQuRatings.sum)/(callQuRatings.count+1)).round(1)
        allCallRatings << avgCallRating
      end
    }
    totalReviews = allCallRatings.count
    avgRate = allCallRatings.count>0 ? ((allCallRatings.sum)/allCallRatings.count).round(1) : 0
    { totalReviews: totalReviews, totalCalls: data.count, avgRating: avgRate}
  end

  def callsDataDetail
    data = CallHistory.where(receiverUserId: self._id).pluck(:totalPrice,:durationMinutes,:callRating,:askedQuestions)
    allCallsAmount = []
    allCallsMinutes = []
    allCallRatings = []
    allCallQuestionsRatings = []
    data.map {|dt| 
      allCallsAmount << dt[0].to_f
      allCallsMinutes << dt[1].to_f
      if dt[2].to_f>0
        callQuRatings = dt[3].to_a.map { |rq| rq["rating"].to_f}
        avgCallRating = ((dt[2].to_f+callQuRatings.sum)/(callQuRatings.count+1)).round(1)
        allCallRatings << avgCallRating
      end
    }
    avgAmount = allCallsAmount.count<=0 ? 0 : (allCallsAmount.sum/allCallsAmount.count).round(2)
    avgMinutes = allCallsMinutes.count<=0 ? 0 : (allCallsMinutes.sum/allCallsMinutes.count).round(2)
    totalReviews = allCallRatings.count
    avgRate = allCallRatings.count>0 ? ((allCallRatings.sum)/allCallRatings.count).round(1) : 0
    { avgAmount: avgAmount, avgMinutes: avgMinutes, totalReviews: totalReviews, totalCalls:  data.count, avgRating: avgRate}
  end

end
