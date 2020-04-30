class Claim < ApplicationRecord
	INSURANCE_POLICY_TYPES = ["Basic Life", "Accidental Death", "TPD", "MVAH"]
	INSURED_CLASSIFICATION = ["Member", "Legal Dependent (Spouse)", "Legal Dependent (Child)", "Legal Dependent (Parent)"]
	CATEGORY_OF_CAUSE_OF_DEATH_TPD_ACCIDENT = ["Cardiovascular", "Respiratory", "Hematological", "Gastro Intestinal", "Gynecological", "Neurological", "Suicide", "Motor Vehicular Accident", "Others"]
  YEAR_LEVEL = ["GRADE 7", "GRADE 8", "GRADE 9", "GRADE 10", "GRADE 11", "GRADE 12", "1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year"]
  TYPES_OF_LOAN = ["K-BAHAY W1","K-BAHAY W2","K-BAHAY W3","K-BENEPISYO W1","K-BENEPISYO W2",
                  "K-BENEPISYO W3","K-EDUKASYON","K-EDUKASYON W2","K-EDUKASYON W3","K-KABUHAYAN",
                  "K-KALAMIDAD","K-KALUSUGAN W1","K-KALUSUGAN W2","K-KALUSUGAN W3","K-KALUSUGAN W4",
                  "K-KALUSUGAN W5","K-KALUSUGAN W6","K-KALUSUGAN W7","K-KASAL","K-KASANGKAPAN","K-MAGGAGAWA",
                  "K-NHA W1","K-NHA W12","K-Noche Buena","K-PWD","K-Toda","K-TRABAHO", "PROJECT LOAN", "MULTI-PURPOSE LOAN", "EMERGENCY LOAN", "UTILITY LOAN", "EDUCATIONAL LOAN"]
  CREDITORS_NAME = ["KCOOP", "JVOMFI", "CAPS-R"]
  GENDER = ["MALE","FEMALE"]
  belongs_to :branch
	belongs_to :center
	belongs_to :member

  before_validation :load_defaults
  def age
    	if self.date_of_birth.nil?
      		"Please set date of birth"
    	else
      		begin
        		now = self.date_of_death_tpd_accident
        		now.year - self.date_of_birth.year - (self.date_of_birth.to_date.change(:year => now.year) > now ? 1 : 0)
      		rescue Exception
        		"Invalid date of birth: #{self.date_of_birth}"
      	end
    end
  end

  def blip_hash

    {
      id: self.id,
      center_id: self.center_id,
      branch_id: self.branch_id,
      member_id: self.member_id,
      claim_type: "BLIP",
      prepared_by: self.prepared_by,
      date_prepared: self.date_prepared,
      created_at: self.created_at,
      updated_at: self.updated_at,
      status: "pending",
      data: {
        policy_number: self.policy_number,
        type_of_insurance_policy: self.type_of_insurance_policy,
        name_of_insured: self.name_of_insured,
        beneficiary: self.beneficiary,
        classification_of_insured: self.classification_of_insured,
        date_of_birth: self.date_of_birth,
        gender: self.gender,
        date_of_policy_issue: self.date_of_policy_issue,
        face_amount: self.face_amount,
        date_of_death_tpd_accident: self.date_of_death_tpd_accident,
        arrears: self.arrears,
        cause_of_death_tpd_accident: self.cause_of_death_tpd_accident,
        age: self.age,
        equity_value: self.equity_value,
        retirement_fund: self.retirement_fund,
        length_of_stay: self.length_of_stay,
        returned_contribution: self.returned_contribution,
        total_amount_payable: self.total_amount_payable,
        amount: self.total_amount_payable,
        order_of_child: self.order_of_child,
        category_of_cause_of_death_tpd_accident: self.category_of_cause_of_death_tpd_accident,
        date_reported: self.date_reported,
        date_paid: self.date_paid
      }
    }
  end

  def load_defaults
    if self.new_record?
      self.status = "pending"
    end
  end

  def checker
    blipnum = 0
    if self.date_prepared.blank? and self.prepared_by.blank?
      blipnum += 1
    end
    return blipnum
  end

  def pending?
    self.status == "pending"
  end

  def approved?
    self.status == "approved"
  end

  # def balance
  #   total = 0.00
    
  #   Claim.where(claim_type: "HIIP").each do |hiip|
  #     if hiip.member_id == self.member_id
  #       hiip_data = hiip.data.with_indifferent_access
  #       total = total + self.data.with_indifferent_access[:amount].to_f
  #     end
  #   end

  #   6000.00 - total 
  # end
  # def new_balance
  #   6000.00 - self.data.with_indifferent_access[:amount].to_f
  # end

  # def old_balance
  #   self.new_balance - self.data.with_indifferent_access[:amount].to_f
  # end
end

