class CalamityClaim < ApplicationRecord
	
	belongs_to :branch
	belongs_to :center
	belongs_to :member

	validates :member, presence: true
	validates :purpose, presence: true
	validates :type_of_calamity, presence: true
	validates :amount, presence: true
	validates :date_of_event, presence: true
	validates :date_of_notification, presence: true
	validates :date_approved, presence: true
	validates :name_of_payee, presence: true
	validates :name_of_beneficiary, presence: true
	validates :date_requested, presence: true

	def calamity_hash

    {
      id: self.id,
      center_id: self.center_id,
      branch_id: self.branch_id,
      member_id: self.member_id,
      claim_type: "CALAMITY ASSISTANCE",
      prepared_by: self.prepared_by,
      date_prepared: self.created_at,
      created_at: self.created_at,
      updated_at: self.updated_at,
      status: "pending",
      data: {
        date_requested: self.date_requested,
        purpose: self.purpose,
        type_of_calamity: self.type_of_calamity,
        amount: self.amount,
        date_of_event: self.date_of_event,
        name_of_payee: self.name_of_payee,
        name_of_beneficiary: self.name_of_beneficiary
      }
    }
  end
end
