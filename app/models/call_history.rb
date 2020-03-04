class CallHistory 
	include Mongoid::Document
  include Mongoid::Timestamps
	
	field :durationMinutes, type: String
  field :pricePerHour, type: Float
  field :totalPrice, type: Float
  field :paidStatus, type: Boolean, default: true

  field :dialerUserId, type: String
  field :receiverUserId, type: String

  belongs_to :dialer, foreign_key: 'dialerUserId',  class_name: "User", inverse_of: :dialedCalls
  belongs_to :receiver, foreign_key: 'receiverUserId',  class_name: "User", inverse_of: :receivedCalls

  has_many :rating_questions, dependent: :destroy
end
