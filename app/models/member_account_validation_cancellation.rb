class MemberAccountValidationCancellation < ApplicationRecord
	belongs_to :branch
	belongs_to :member_account_validation
	belongs_to :member

	validates :member_id, presence: true
	validates :date_cancelled, presence: true
	validates :reason, presence: true
end
