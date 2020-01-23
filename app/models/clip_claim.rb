class ClipClaim < ApplicationRecord
	GENDER = ["Male", "Female"]
	CREDITORS_NAME = ["KCOOP", "JVOMFI", "CAPS-R"]
  CAUSE_OF_DEATH = ["Cardiovascular", "Respiratory", "Hematological", "Gastro Intestinal", "Gynecological", "Neurological", "Suicide", "Others"]
  TYPES_OF_LOAN = ["K-BAHAY W1","K-BAHAY W2","K-BAHAY W3","K-BENEPISYO W1","K-BENEPISYO W2",
                  "K-BENEPISYO W3","K-EDUKASYON","K-EDUKASYON W2","K-EDUKASYON W3","K-KABUHAYAN",
                  "K-KALAMIDAD","K-KALUSUGAN W1","K-KALUSUGAN W2","K-KALUSUGAN W3","K-KALUSUGAN W4",
                  "K-KALUSUGAN W5","K-KALUSUGAN W6","K-KALUSUGAN W7","K-KASAL","K-KASANGKAPAN","K-MAGGAGAWA",
                  "K-NHA W1","K-NHA W12","K-Noche Buena","K-PWD","K-Toda","K-TRABAHO"]

	belongs_to :branch
	belongs_to :center
	belongs_to :member

	validates :member, presence: true
  validates :date_prepared, presence: true
  validates :creditors_name, presence: true
  validates :policy_number, presence: true
  validates :date_of_birth, presence: true
  validates :member_name, presence: true
  validates :beneficiary, presence: true
  validates :gender, presence: true
  validates :age, presence: true
  validates :date_of_death, presence: true
  validates :cause_of_death, presence: true
  validates :effective_date_of_coverage, presence: true 
  validates :expiration_date_of_coverage, presence: true
  validates :amount_of_loan, presence: true
  validates :terms, presence: true
  validates :amount_payable_to_beneficiary, presence: true
  validates :amount_payable_to_creditor, presence: true
  validates :type_of_loan, presence: true

	def age
    if self.date_of_birth.nil?
      "Please set date of birth"
    else
      begin
        now = self.date_of_death
        now.year - self.date_of_birth.year - (self.date_of_birth.to_date.change(:year => now.year) > now ? 1 : 0)
      rescue Exception
        "Invalid date of birth: #{self.date_of_birth}"
      end
    end
	end
end
