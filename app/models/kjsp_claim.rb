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

	def scholarship_hash

    {
      id: self.id,
      center_id: self.center_id,
      branch_id: self.branch_id,
      member_id: self.member_id,
      claim_type: "KUYA JUN SCHOLARSHIP PROGRAM",
      prepared_by: self.prepared_by,
      date_prepared: self.date_prepared,
      created_at: self.created_at,
      updated_at:  self.updated_at,
      status: "pending",
      data: {
        name_of_beneficiary: self.name_of_kjsp_beneficiary,
        payee: self.payee,
        name_of_school: self.name_of_school,
        amount: self.amount,
        school_year: self.school_year,
        year_level: self.year_level,
        sem: self.sem,
        scholarship_type: self.kjsp_type,
        final_grade: self.final_grade,
        classification: self.classification,
        course: self.course
      }
    }
  end
end
