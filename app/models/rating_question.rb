class RatingQuestion
	include Mongoid::Document
  include Mongoid::Timestamps

  field :question, type: String
  field :rating, type: Float, default: 5
  field :receiverUserId, type: String
  field :isAnswered, type: Boolean, default: true

  belongs_to :call_history
  belongs_to :user, inverse_of: :rating_questions
  belongs_to :receiver, foreign_key: 'receiverUserId',  class_name: "User", inverse_of: :received_rating_questions

end