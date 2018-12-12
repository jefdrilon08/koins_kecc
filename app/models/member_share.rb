class MemberShare < ApplicationRecord
  belongs_to :member

  validates :certificate_number, presence: true

  scope :printed, -> { where("member_shares.data->>'printed' = ?", "true") }
  scope :not_printed, -> { where.not("member_shares.data->>'printed' = ?", "true") }

  def to_s
    self.certificate_number
  end
end
