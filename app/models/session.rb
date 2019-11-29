class Session
	include Mongoid::Document
  include Mongoid::Timestamps

  field :sessionToken, type: String
	field :deviceId, type: String
	field :deviceType, type: String

	belongs_to :user

	before_create :generateSessionToken

	def generateSessionToken
		self.sessionToken = generateToken
	end

	def generateToken
		loop do
      token = SecureRandom.urlsafe_base64
      break token unless  Session.where(sessionToken: token).exists?
    end
	end

end