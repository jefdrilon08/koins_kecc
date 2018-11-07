class UserBranch < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where.not(active: true) }

  belongs_to :user
  belongs_to :branch

  before_validation :load_defaults
  
  def load_defaults
  end
end
