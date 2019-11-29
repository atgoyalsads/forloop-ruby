class SubcategoryUser 	
	include Mongoid::Document
  include Mongoid::Timestamps

	belongs_to :subcategory
	belongs_to :user

	validates :subcategory, uniqueness: { scope: [:user] }
end