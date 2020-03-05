class Member < ApplicationRecord
  include Rails.application.routes.url_helpers

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
  INSURANCE_STATUS = ["inforce", "lapsed", "resigned", "dormant", "pending", "cleared", "archived"]
  MEMBER_TYPES = ["Regular", "GK", "Kaagapay"]

  belongs_to :center
  belongs_to :branch

  has_many :loans
  has_many :legal_dependents, dependent: :delete_all
  has_many :beneficiaries, dependent: :delete_all
  has_many :member_accounts, dependent: :delete_all
  has_many :member_shares
  has_many :membership_payment_records
  has_many :claims, dependent: :delete_all
  has_many :clip_claims, dependent: :delete_all
  has_many :hiip_claims, dependent: :delete_all
  has_many :kbente_claims, dependent: :delete_all
  has_many :kjsp_claims, dependent: :delete_all
  has_many :calamity_claims, dependent: :delete_all
  has_many :membership_payment_records
  has_many :attachment_files
  has_many :member_account_validation_records

  # ActiveStorage
  #has_many_attached :attachment_files
  has_one_attached :profile_picture
  has_one_attached :signature_file

  validates :gender, presence: true
  validates :date_of_birth, presence: true

  validates :first_name, presence: true
  #validates :middle_name, presence: true
  validates :last_name, presence: true

  #validates :identification_number, presence: true, uniqueness: true, if: :active?
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
  scope :insurance_resigned, -> { where(insurance_status: "resigned").order("last_name ASC") }
  scope :insurance_active, -> { where(status: "active", insurance_status: ["inforce", "lapsed"]).order("last_name ASC") }

  before_validation :load_defaults

  def is_returning?
    self.status == "active"  and (self.previous_date_resigned.present? || (self.data.with_indifferent_access[:resignation_records].present? and self.data.with_indifferent_access[:resignation_records].size > 0))
  end
  
  def check_name
    "#{first_name.try(:upcase)} #{middle_name.try(:upcase)} #{last_name.try(:upcase)}"
  end

  def full_name
    "#{self.last_name}, #{self.first_name}, #{self.middle_name}"
  end

  def full_name_with_center
    "#{self.last_name}, #{self.first_name}, #{self.middle_name} (#{self.center})"
  end

  def full_address_upcase
    "#{self.data.with_indifferent_access[:address][:street].upcase}, #{self.data.with_indifferent_access[:address][:district].upcase}, #{self.data.with_indifferent_access[:address][:city].upcase}, PH"
  end

  def recognition_date
    if self.data.with_indifferent_access[:recognition_date].present?
      return self.data.with_indifferent_access[:recognition_date].to_date
    else
      return nil
    end
  end

  def profile_picture_url
    if self.profile_picture.attached? and self.profile_picture.representable?
      return rails_blob_path(self.profile_picture, disposition: "attachment", only_path: true)
    else
      "https://#{ENV.fetch('APP_HOST')}#{ActionController::Base.helpers.asset_path('missing_profile_picture.png')}"
    end
  end

  def signature_url
    if self.signature_file.attached?
      return rails_blob_path(self.signature_file, disposition: "attachment", only_path: true)
    end
  end

  def has_signature?
    self.signature_file.attached?
  end

  def full_name_titleize
    "#{last_name.try(:titleize)}, #{first_name.try(:titleize)} #{middle_name.try(:titleize)}"  
  end

  def resigned?
    self.status == "resigned"
  end

  def pending?
    self.status == "pending"
  end

  def pending_dormant?
    self.insurance_status == "dormant" or self.insurance_status == "pending"
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

  def date_of_membership
    default_membership_name = Settings.try(:default_membership).try(:name)
    default_membership_type = Settings.try(:default_membership).try(:type)

    if default_membership_name.present? and default_membership_type.present?
      record  = MembershipPaymentRecord.paid.where(
                  "member_id = ? AND membership_type = ? AND membership_name = ?",
                  self.id,
                  default_membership_type,
                  default_membership_name
                ).order(
                  "date_paid DESC"
                ).first
    else
      record  = MembershipPaymentRecord.paid.where(
                  "member_id = ?",
                  self.id
                ).order(
                  "date_paid DESC"
                ).first
    end

    if record.present?
      record.date_paid.strftime("%b %d, %Y")
    else
      if Settings.try(:use_recognition_date) == true and self.recognition_date.present?
        self.recognition_date.strftime("%b %d, %Y")
      else
        ""
      end
    end
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

  def spouse_date_of_birth
    spouse_data = data.with_indifferent_access[:spouse]
    "#{spouse_data[:date_of_birth]}"
  end

  def age 
    if self.date_of_birth.nil?
      "Please set date of birth"
    else
      begin
        now = Time.now.utc.to_date
        now.year - self.date_of_birth.year - ((now.month > self.date_of_birth.month || (now.month == self.date_of_birth.month && now.day >= self.date_of_birth.day)) ? 0 : 1)
        #now.year - self.date_of_birth.year - (self.date_of_birth.to_date.change(:year => now.year) > now ? 1 : 0)
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

    self.first_name   = self.first_name.try(:upcase)
    self.last_name    = self.last_name.try(:upcase)
    self.middle_name  = self.middle_name.try(:upcase)
  end

  def equity_value
    self.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").sum(:balance)
  end
  def lif_amount
    self.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").sum(:balance)
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
    "#{first_name.try(:titleize)} #{middle_name.try(:titleize)} #{last_name.try(:titleize)}"  
  end

 def spouse_age
    if self.data.with_indifferent_access[:spouse][:date_of_birth].nil?
      0
    else
      begin
        now = Time.now.utc.to_date
        now.year - self.data.with_indifferent_access[:spouse][:date_of_birth].to_date.year - ((now.month > self.data.with_indifferent_access[:spouse][:date_of_birth].to_date.month || (now.month == self.data.with_indifferent_access[:spouse][:date_of_birth].to_date.month && now.day >= self.data.with_indifferent_access[:spouse][:date_of_birth].to_date.day)) ? 0 : 1)
        #((Time.zone.now - self.data['spouse']['date_of_birth'].to_time) / 1.year.seconds).floor
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

           
