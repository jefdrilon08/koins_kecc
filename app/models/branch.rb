class Branch < ApplicationRecord

  validates :name, presence: true
  validates :short_name, presence: true


  belongs_to :cluster
  has_many :centers
end
