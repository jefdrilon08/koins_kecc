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
  INSURANCE_STATUS = ["inforce", "lapsed", "resigned", "dormant", "pending", "cleared"]
  MEMBER_TYPES = ["Regular", "GK", "Kaagapay"]

  belongs_to :center
  belongs_to :branch

  has_many :loans
  has_many :legal_dependents
  has_many :beneficiaries
  has_many :member_accounts
  has_many :member_shares
  has_many :membership_payment_records
  has_many :claims, dependent: :delete_all
  has_many :membership_payment_records
  has_many :attachment_files

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
  scope :active_and_resigned_and_pending, -> { where(status: ["active", "resigned", "pending"]).order("last_name ASC") }
  scope :returning, -> { where("status = ? AND previous_date_resigned IS NOT NULL", "active").order("last_name ASC") }

  before_validation :load_defaults

  def is_returning?
    self.status == "active"  and (self.previous_date_resigned.present? || (self.data.with_indifferent_access[:resignation_records].present? and self.data.with_indifferent_access[:resignation_records].size > 0))
  end
  
  def check_name
    "#{first_name.upcase} #{middle_name.upcase} #{last_name.upcase}"
  end

  def full_name
    "#{self.last_name}, #{self.first_name}, #{self.middle_name}"
  end

  def full_name_with_center
    "#{self.last_name}, #{self.first_name}, #{self.middle_name} (#{self.center})"
  end

  def recognition_date
    if self.data.with_indifferent_access[:recognition_date].present?
      return self.data.with_indifferent_access[:recognition_date].to_date
    else
      return nil
    end
  end

  def full_name_titleize
    "#{last_name.titleize}, #{first_name.titleize} #{middle_name.titleize}"  
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
    
      if self.data.with_indifferent_access[:recognition_date].present?
        self.status = "active"
        self.insurance_status = "dormant"
      end
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

  def length_of_stay
    if self.data.with_indifferent_access[:recognition_date].present?
      now = Time.now
      seconds_between = (now.to_time - self.data.with_indifferent_access[:recognition_date].to_time).abs 
      days_between = seconds_between / 60 / 60 / 24
      number_of_days = days_between.floor
      number_of_months = (days_between / 30.44).floor
      years = (days_between / 365.242199).floor
      months = number_of_months - (years * 12)
      if years < 1
        if months > 1
          "#{months} MONTHS"
        elsif months == 1
          "#{months} MONTH"
        elsif months < 1
          if number_of_days == 1 
            "#{number_of_days} DAY"
          elsif number_of_days > 1
            "#{number_of_days} DAYS"
          elsif number_of_days < 1
            nil          
          end
        end    
      else
        if years == 1 && months == 0 
          "#{years} YEAR"
        elsif years == 1 && months == 1
          "#{years} YEAR, #{months} MONTH"
        elsif years == 1 && months > 1
          "#{years} YEAR, #{months} MONTHS"
        elsif years > 1 && months > 1
          "#{years} YEARS, #{months} MONTHS"
        elsif years > 1 && months == 1
          "#{years} YEARS, #{months} MONTH"
        elsif years > 1 && months < 1
          "#{years} YEARS"    
        end
      end
    end
  end

  def full_name_formatted
    "#{first_name.titleize} #{middle_name.titleize} #{last_name.titleize}"  
  end

 def spouse_age
    if self.data['spouse']['date_of_birth'].nil?
      0
    else
      begin
        ((Time.zone.now - self.data['spouse']['date_of_birth'].to_time) / 1.year.seconds).floor
      rescue Exception
        "Invalid date of birth: #{self.data['spouse']['date_of_birth']}"
      end
    end
  end

  def full_name_middle_initial
    if self.middle_name == ""
      "#{last_name.titleize}, #{first_name.titleize}"
    else
      "#{last_name.titleize}, #{first_name.titleize} #{middle_name[0].try(:titleize)}."
    end
  end

end

           