class MemberShare < ApplicationRecord
  belongs_to :member

  validates :certificate_number, presence: true

  def to_s
    self.certificate_number
  end
end
