class Subcategory
	include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String

  belongs_to :category

  validates :title, presence: true
  validates :title, uniqueness: { scope: [:category] }
  
  def id
  	self._id.as_json["$oid"]
  end

end