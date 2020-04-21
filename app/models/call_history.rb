class CallHistory 
	include Mongoid::Document
  include Mongoid::Timestamps
	
	field :durationMinutes, type: Float, default: 0.0
  field :pricePerHour, type: Float
  field :totalPrice, type: Float
  field :tip, type: Float, default: 0.0
  field :callReview, type: String
  field :callRating, type: Float
  field :feedbackQuestionAddressed, type: Boolean, default: true
  field :feedbackNotLiked, type: String
  field :feedbackNewFeatures, type: String
  field :paidStatus, type: Boolean, default: false
  field :callStatus, type: String, default: "initiated"
  field :callCategory, type: String
  field :callId, type: String
  field :stripeChargeId, type: String
  field :stripeMessage, type: String


  field :connectedAt, type: DateTime
  field :pickedAt, type: DateTime
  field :completedAt, type: DateTime
  
  field :dialerUserId, type: String
  field :receiverUserId, type: String
  field :askedQuestions, type: Array

  belongs_to :dialer, foreign_key: 'dialerUserId',  class_name: "User", inverse_of: :dialedCalls
  belongs_to :receiver, foreign_key: 'receiverUserId',  class_name: "User", inverse_of: :receivedCalls

  has_many :rating_questions, dependent: :destroy

  def id
    self._id.as_json["$oid"]
  end

  def rating
    qRt = self.rating_questions.pluck(:rating).map{ |v| v.to_f }
    ((self.callRating.to_f+qRt.sum)/(qRt.count+1)).round(1)
  end

  def receiverId
    self.receiverUserId.to_s
  end

  def reviewedBy
    u = self.dialer.displayName
  end

end
