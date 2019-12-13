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
end
