class Category
	include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String

  has_many :subcategories, dependent: :destroy

  validates :title, presence: true

  def id
  	self._id.as_json["$oid"]
  end

end