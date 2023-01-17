class Claim < ApplicationRecord
	INSURANCE_POLICY_TYPES = ["Basic Life", "Accidental Death", "TPD", "MVAH"]
	INSURED_CLASSIFICATION = ["Member", "Legal Dependent (Spouse)", "Legal Dependent (Child)", "Legal Dependent (Parent)"]
	CATEGORY_OF_CAUSE_OF_DEATH_TPD_ACCIDENT = ["Cardiovascular", "Respiratory", "Hematological", "Gastro Intestinal", "Gynecological", "Neurological", "Suicide", "Motor Vehicular Accident", "Others"]
  YEAR_LEVEL = ["GRADE 7", "GRADE 8", "GRADE 9", "GRADE 10", "GRADE 11", "GRADE 12", "1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year"]
  TYPES_OF_LOAN = ["K-BAHAY W1", "K-BAHAY W2", "K-BAHAY W3",
                   "K-BENEPISYO W1", "K-BENEPISYO W2", "K-BENEPISYO W3",
                   "K-MOTORSIKLO",
                   "K-EDUKASYON", "K-EDUKASYON W2", "K-EDUKASYON W3","K-EDUKASYON W4",
                   "K-KALUSUGAN W1", "K-KALUSUGAN W2","K-KALUSUGAN W3","K-KALUSUGAN W4", "K-KALUSUGAN W5","K-KALUSUGAN W6","K-KALUSUGAN W7",
                   "K-KABUHAYAN", "K-KABUHAYAN W2", "K-KABUHAYAN W3", "K-KALAMIDAD", "K-SAGIP", "K-KASAL", "K-KASANGKAPAN", "K-MAGGAGAWA", "K (BUSINESS DISRUPTION LOAN)",
                   "K-NHA W1", "K-NHA W12", "K-Noche Buena", "K-PWD", "K-Toda", "K-TRABAHO", "K-ALALAY W2", "K-YAKAP",
                   "PROJECT LOAN", "MULTI-PURPOSE LOAN", "EMERGENCY LOAN", "UTILITY LOAN", "EDUCATIONAL LOAN","REGULAR LOAN", "RECOVERY LOAN"
                ]
  CREDITORS_NAME = ["KCOOP", "JVOMFI", "CAPS-R", "KEEPFAI"]
  GENDER = ["MALE","FEMALE"]
  CREDITORS_NAME_FULL = ["KABUHAYAN SA GANAP NA KASARINLAN CREDIT AND SAVINGS COOPERATIVE", "CEBU ARCHDIOCESAN PROGRAM FOR SELF RELIANCE INC.-CAPS-R", "CAPS-R INC (A MICROFINANCE NGO)", "KASAGANA-KA EMPLOYEE-EMPLOYER'S PROVIDENT FUND ASSOCIATION INC."]

  belongs_to :branch
	belongs_to :center
	belongs_to :member, optional: true

  has_many :claim_attachment_files, dependent: :delete_all

  before_validation :load_defaults

  def transaction_fee
    temp_data = self.data.with_indifferent_access

    temp_data[:transaction_fee]
  end

  def book
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:book]
  end

  def particular
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:particular]
  end

  def or_number
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:data][:or_number]
  end

  def check_number
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:data][:check_number]
  end

  def check_voucher_number
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:data][:check_voucher_number]
  end

  def payee
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:data][:payee]
  end

  def note
    data = self.data.with_indifferent_access

    data[:note]
  end

  def declined_note
    data = self.data.with_indifferent_access

    data[:declined_note]
  end

  def proceed_checking?
    self.data.with_indifferent_access[:for_proceed] == true
  end

  def online_transaction?
    self.data.with_indifferent_access[:transaction_type] == "Online"
  end

  def check_transaction?
    self.data.with_indifferent_access[:transaction_type] == "Check"
  end

  def claims_template
    temp_data = self.data.with_indifferent_access 

    if temp_data[:claims_template].present?
      temp_data[:claims_template]
    else
      "default"
    end
  end

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

  def for_approval?
    self.status == "for-approval"
  end

  def for_posting?
    self.status == "for-posting"
  end

  def blip?
    self.claim_type == "BLIP"
  end

  def clip?
    self.claim_type == "CLIP"
  end

  def hiip?
    self.claim_type == "HIIP"
  end

  def calamity?
    self.claim_type == "CALAMITY ASSISTANCE"
  end

  def kjsp?
    self.claim_type == "KUYA JUN SCHOLARSHIP PROGRAM"
  end

  def kalinga?
    self.claim_type == "K-KALINGA"
  end

  def kbente?
    self.claim_type == "K-BENTE"
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
  def find_in_batches(start: nil, finish: nil, batch_size: 500, error_on_ignore: nil)
    relation = self
    unless block_given?
      return to_enum(:find_in_batches, start: start, finish: finish, batch_size: batch_size, error_on_ignore: error_on_ignore) do
        total = apply_limits(relation, start, finish).size
        (total - 1).div(batch_size) + 1
      end
    end
    
    in_batches(of: batch_size, start: start, finish: finish, load: true, error_on_ignore: error_on_ignore) do |batch|
      yield batch.to_a
    end
  end
  
end

