class MemberShare < ApplicationRecord
  belongs_to :member

  validates :certificate_number, presence: true

  scope :printed, -> { where("member_shares.data->>'printed' = ?", "true") }
  scope :not_printed, -> { where("member_shares.data->>'printed' = ?", "false") }

  def to_s
    self.certificate_number
  end

  def for_kmba?
  	self.certificate_for == "KMBA"
  end

  def for_kcoop?
  	self.certificate_for == "KCOOP" || self.certificate_for == nil
  end
end
