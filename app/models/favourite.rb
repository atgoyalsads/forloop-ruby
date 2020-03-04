class Favourite
	include Mongoid::Document
  include Mongoid::Timestamps

  field :favouriteUserId, type: String

  belongs_to :user, inverse_of: :favourites
  belongs_to :favouriteUser, foreign_key: 'favouriteUserId',  class_name: "User", inverse_of: :in_favourites

end