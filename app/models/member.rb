class Member < ApplicationRecord
  STATUSES = [
    "blacklisted",
    "whitelisted",
    "active",
    "pending",
    "resign",
    "archived",
    "resigned",
    "for-resignation",
    "dormant",
    "for-withdrawal",
    "for-transfer",
    "transferred",
    "cleared"
  ]

  belongs_to :center
  belongs_to :branch

  has_many :loans
  has_many :legal_dependents
  has_many :beneficiaries
  has_many :member_accounts
  has_many :member_shares
  has_many :claims, dependent: :delete_all

  validates :gender, presence: true
  validates :date_of_birth, presence: true

  validates :first_name, presence: true
  #validates :middle_name, presence: true
  validates :last_name, presence: true

  validates :identification_number, presence: true, uniqueness: true, if: :active?
  validates :civil_status, presence: true
  #validates :home_number, presence: true
  #validates :mobile_number, presence: true

  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active").order("last_name ASC") }
  scope :pending, -> { where(status: "pending").order("last_name ASC") }
  scope :resigned, -> { where(status: "resigned").order("last_name ASC") }
  scope :active_and_resigned, -> { where(status: ["active", "resigned"]).order("last_name ASC") }

  before_validation :load_defaults

  def full_name
    "#{last_name}, #{first_name} #{middle_name}"
  end

  def resigned?
    self.status == "resigned"
  end

  def pending?
    self.status == "pending"
  end

  def active?
    self.status == "active"
  end

  def not_active?
    self.status != "active"
  end

  def entry_point_loan_cycle_count
    self.data.with_indifferent_access[:entry_point_loan_cycle] || 0
  end

  def resignation_records
    if self.data.with_indifferent_access[:resignation_records].blank?
      []
    else
      self.data.with_indifferent_access[:resignation_records]
    end
  end

  # Fetch the member's resignation details
  def resignation
    {
      identification_number: self.identification_number,
      date_resigned: self.date_resigned,
      data: self.data.with_indifferent_access[:resignation]
    }
  end

  def insurance_pending?
    self.insurance_status == "pending"
  end

  def fetch_government_id(type)
    data_hash = self.data.with_indifferent_access[:government_identification_numbers]

    if type == "sss_number" 
      data_hash[:sss_number]
    elsif type == "pag_ibig_number"
      data_hash[:pag_ibig_number]
    elsif type == "phil_health_number"
      data_hash[:phil_health_number]
    elsif type == "tin_number"
      data_hash[:tin_number]
    end
  end

  def housing_type
    data.with_indifferent_access[:housing][:type]
  end

  def spouse
    spouse_data = data.with_indifferent_access[:spouse]

    "#{spouse_data[:last_name]}, #{spouse_data[:first_name]} #{spouse_data[:middle_name]}"
  end

  def age 
    if self.date_of_birth.nil?
      "Please set date of birth"
    else
      begin
        now = Time.now.utc.to_date
        now.year - self.date_of_birth.year - (self.date_of_birth.to_date.change(:year => now.year) > now ? 1 : 0)
      rescue Exception
        "Invalid date of birth: #{self.date_of_birth}"
      end 
    end 
  end

  def load_defaults
    if self.new_record?
      self.status = "pending"
      self.insurance_status = "pending"
    end

    self.first_name   = self.first_name.upcase
    self.last_name    = self.last_name.upcase
    self.middle_name  = self.middle_name.upcase
  end

  def equity_value
    self.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").sum(:balance)/2
  end

  def rf_amount
    self.member_accounts.where(account_type: "INSURANCE", account_subtype: "Retirement Fund").sum(:balance)
  end
end
