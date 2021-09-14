class MembershipArrangement < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  before_validation :load_defaults

  def to_s
    name
  end

  def load_defaults
    if self.name.present?
      self.name = self.name.upcase
    end
  end
end
