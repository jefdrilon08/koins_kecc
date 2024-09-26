class MemberShare < ApplicationRecord
  belongs_to :member

  validates :certificate_number, presence: true

  scope :printed, -> { where("member_shares.data->>'printed' = ?", "true") }
  scope :not_printed, -> { where("member_shares.data->>'printed' = ?", "false") }

  before_save :update_certificate_for

  def update_certificate_for  
    self.certificate_for = is_void ? 'VOID' : 'KCOOP'
  end

  def to_s
    self.certificate_number
  end

  def for_kmba?
  	self.certificate_for == "KMBA"
  end

  def for_kcoop?
  	self.certificate_for == "KCOOP" || self.certificate_for == nil
  end

  def for_void
    if is_void
      self.certificate_for = "VOID"
    else
      self.certificate_for = "KCOOP"
    end
  end
end
