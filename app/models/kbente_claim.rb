class KbenteClaim < ApplicationRecord

	belongs_to :branch
	belongs_to :center
	belongs_to :member

	validates :member, presence: true
	validates :date_reported, presence: true
	validates :date_emailed, presence: true
	validates :date_approved, presence: true
	validates :date_requested, presence: true
	validates :purpose, presence: true
	validates :amount, presence: true
	validates :name_of_insured, presence: true
	validates :name_of_beneficiary, presence: true
	validates :classification, presence: true
	validates :date_of_death, presence: true

	def kbente_hash

    {
      id: self.id,
      center_id: self.center_id,
      branch_id: self.branch_id,
      member_id: self.member_id,
      claim_type: "K-BENTE",
      prepared_by: self.prepared_by,
      date_prepared: self.created_at,
      created_at: self.created_at,
      updated_at: self.updated_at,
      status: "pending",
      data: {
        date_approved: self.date_approved,
        date_of_birth: self.member.date_of_birth,
        purpose: self.purpose,
        amount: self.amount,
        name_of_insured: self.name_of_insured,
        name_of_beneficiary: self.name_of_beneficiary,
        classification: self.classification,
        date_of_death: self.date_of_death,
        date_enrolled: self.created_at,
        date_expired: self.created_at
      }
    }
  end
end
