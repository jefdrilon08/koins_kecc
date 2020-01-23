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
end
