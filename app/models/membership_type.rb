class MembershipType < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  before_validation :load_defaults

  def to_s
    name
  end

  def load_defaults
  end
end
