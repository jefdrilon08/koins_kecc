class KjspClaim < ApplicationRecord
	YEAR_LEVEL = ["GRADE 7","GRADE 8","GRADE 9","GRADE 10","GRADE 11","GRADE 12","1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year"]
	belongs_to :branch
	belongs_to :center
	belongs_to :member

	validates :member, presence: true
	validates :date_prepared, presence: true
	validates :name_of_kjsp_beneficiary, presence: true
	validates :payee, presence: true
	validates :amount, presence: true
	validates :name_of_school, presence: true
	validates :school_year, presence: true
	validates :year_level, presence: true
	validates :sem, presence: true
	validates :kjsp_type, presence: true
	validates :final_grade, presence: true
	validates :classification, presence: true
end
