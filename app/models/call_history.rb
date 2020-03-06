class CallHistory 
	include Mongoid::Document
  include Mongoid::Timestamps
	
	field :durationMinutes, type: Float, default: 0.0
  field :pricePerHour, type: Float
  field :totalPrice, type: Float
  field :paidStatus, type: Boolean, default: false
  field :callStatus, type: String, default: "initiated"
  
  field :connectedAt, type: DateTime
  field :pickedAt, type: DateTime
  field :endedAt, type: DateTime

  field :dialerUserId, type: String
  field :receiverUserId, type: String

  belongs_to :dialer, foreign_key: 'dialerUserId',  class_name: "User", inverse_of: :dialedCalls
  belongs_to :receiver, foreign_key: 'receiverUserId',  class_name: "User", inverse_of: :receivedCalls

  has_many :rating_questions, dependent: :destroy

  before_save :update_rec

  def id
    self._id.as_json["$oid"]
  end

  def update_rec
    puts "======================================"
    self.set({updated_at: Time.current})
  end
end
