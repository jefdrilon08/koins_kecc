class Member < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :member, optional: true

  devise :database_authenticatable

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
    "cleared",
    "dependent",
    "writeoff",
    "delinquent"
  ]

  INSURANCE_STATUS = [
    "inforce",
    "lapsed",
    "resigned",
    "dormant",
    "pending",
    "inactive"
  ]

  MEMBER_TYPES = [
    "Regular",
    "GK",
    "Kaagapay",
    "Dependent",
    "Non-Member"
  ]

  belongs_to :online_application, optional: true

  belongs_to :center
  belongs_to :branch
  belongs_to :membership_arrangement, optional: true
  belongs_to :membership_type, optional: true
  belongs_to :referrer, optional: true

  has_many :loans
  has_many :legal_dependents, dependent: :delete_all
  has_many :beneficiaries, dependent: :delete_all
  has_many :member_accounts, dependent: :delete_all
  has_many :member_shares
  has_many :membership_payment_records
  has_many :claims
  has_many :clip_claims, dependent: :delete_all
  has_many :hiip_claims, dependent: :delete_all
  has_many :kbente_claims, dependent: :delete_all
  has_many :kjsp_claims, dependent: :delete_all
  has_many :calamity_claims, dependent: :delete_all
  has_many :kalinga_claims, dependent: :delete_all
  has_many :membership_payment_records
  has_many :attachment_files, dependent: :delete_all
  has_many :member_account_validation_records

  # ActiveStorage
  #has_many_attached :attachment_files
  has_one_attached :profile_picture, dependent: false
  has_one_attached :signature_file

  # Validate email only if present
  #validates :email, presence: false, uniqueness: true, if: Proc.new { |member| member.email.blank? }

  validates :gender, presence: true
  validates :date_of_birth, presence: true

  validates :first_name, presence: true
  #validates :middle_name, presence: true
  validates :last_name, presence: true

  #validates :identification_number, presence: true, uniqueness: true, if: :active?
  #validates :civil_status, presence: true
  #validates :home_number, presence: true
  #validates :mobile_number, presence: true

  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active").order("last_name ASC") }
  scope :pending, -> { where(status: "pending").order("last_name ASC") }
  scope :resigned, -> { where(status: "resigned").order("last_name ASC") }
  scope :active_and_resigned, -> { where(status: ["active", "resigned"]).order("last_name ASC") }
  scope :active_and_involutary, -> { where("data->>'hide_status' IN (?)", ["active", "involuntary"]).order("last_name ASC") }
  scope :active_and_resigned_and_writeoff, -> { where(status: ["active", "resigned", "writeoff"]).order("last_name ASC") }
  scope :active_and_resigned_and_pending, -> { where(status: ["active", "resigned", "pending"]).order("last_name ASC") }
  scope :returning, -> { where("status = ? AND previous_date_resigned IS NOT NULL", "active").order("last_name ASC") }
  scope :insurance_resigned, -> { where(insurance_status: "resigned").order("last_name ASC") }
  scope :insurance_active, -> { where(status: "active", insurance_status: ["inforce", "lapsed", "dormant"]).order("last_name ASC") }
  scope :inforce, -> { where(status: "active", insurance_status: "inforce").order("last_name ASC") }
  scope :reinstate, -> { where(status: "active").where("data->>'reinstatement' IS NOT NULL").order("last_name ASC") }
  scope :inforce_pending, -> { where(status: "active", insurance_status: ["inforce", "pending"]).order("last_name ASC") }
  before_validation :load_defaults

  def user_object
    {
      username: username,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      full_name: full_name,
      identification_number: identification_number,
      branch: branch.name,
      center: center.name
    }
  end

  def is_returning?
    self.status == "active"  and (self.previous_date_resigned.present? || (self.data.with_indifferent_access[:resignation_records].present? and self.data.with_indifferent_access[:resignation_records].any?))
  end

  def member_shares_records
    if self.member_shares.present?
      return self.member_shares.printed.last.data.with_indifferent_access[:date_printed].to_date
    else
      return "Not printed"
    end
  end

  def equity_value
    self.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").sum(:balance) / 2
  end


  def check_name
    "#{first_name.try(:upcase)} #{last_name.try(:upcase)}"
  end

  def full_name
    "#{self.last_name}, #{self.first_name}, #{self.middle_name}"
  end

  def mother_maiden_name
    "#{self.data.with_indifferent_access[:mothers_last_name]}, #{self.data.with_indifferent_access[:mothers_first_name]} #{self.data.with_indifferent_access[:mothers_middle_name]}"
  end

  def full_name_with_center
    "#{self.last_name}, #{self.first_name}, #{self.middle_name} (#{self.center})"
  end

  def full_address_upcase
    "#{self.data.with_indifferent_access[:address][:street].upcase}, #{self.data.with_indifferent_access[:address][:district].upcase}, #{self.data.with_indifferent_access[:address][:city].upcase}, #{self.data.with_indifferent_access[:address][:province].upcase} , #{self.data.with_indifferent_access[:address][:region].upcase} , PH"
  end

  def full_address
    "#{self.data.with_indifferent_access[:address][:street]}, #{self.data.with_indifferent_access[:address][:district]}, #{self.data.with_indifferent_access[:address][:city]}, #{self.data.with_indifferent_access[:address][:province]} , #{self.data.with_indifferent_access[:address][:region]} , PH"
  end

  def recognition_date
    if self.data.with_indifferent_access[:recognition_date].present?
      return self.data.with_indifferent_access[:recognition_date].to_date
    else
      return nil
    end
  end

  def face_amount
    if self.data.with_indifferent_access[:recognition_date].present?
      now = Time.now

      value1 = 2000
      value2 = 6000
      value3 = 10000
      value4 = 30000
      value5 = 50000


      number_of_days = (now.to_date - self.data.with_indifferent_access[:recognition_date].to_date).to_i


      if number_of_days <= 91
        "₱#{value1}.00"
      elsif number_of_days >= 92 && number_of_days <= 365
        "₱#{value2}.00"
      elsif number_of_days >= 366 && number_of_days <= 730
        "₱#{value3}.00"
      elsif number_of_days >= 731 && number_of_days <= 1095
        "₱#{value4}.00"
      elsif number_of_days >= 1096
        "₱#{value5}.00"
      end
    end
  end

  def from_mobile_app
    if self.data.with_indifferent_access[:from_mobile_app].present?
      return self.data.with_indifferent_access[:from_mobile_app]
    else
      return nil
    end
  end

  def interest_start_date
    if self.data.with_indifferent_access[:restoration_records].blank?
      return self.data.with_indifferent_access[:recognition_date]
    else
      return self.data.with_indifferent_access[:restoration_records][0][:date_restored]
    end
  end

  def reinstatement_date
    if self.data.with_indifferent_access[:reinstatement][:reinstatement_date].present?
      return self.data.with_indifferent_access[:reinstatement][:reinstatement_date].to_date
    else
      return nil
    end
  end

  def old_recognition_date
    if self.data.with_indifferent_access[:reinstatement][:old_recognition_date].present?
      return self.data.with_indifferent_access[:reinstatement][:old_recognition_date].to_date
    else
      return nil
    end
  end

  def life_number_of_lapsed
    ma = self.member_accounts.where(account_subtype:"Life Insurance Fund").first

    if ma.present?
      recognition_date = self.data.with_indifferent_access[:recognition_date].to_date
      current_date = Date.today.to_date

      current_balance   = ma.balance
      num_days = (current_date - recognition_date).to_i
      num_weeks  = (num_days / 7).to_i + 1
      insured_amount  = num_weeks  * 15
      amt_past_due    = (current_balance - insured_amount) * -1
      num_weeks_past_due  = (amt_past_due / 15).to_i

      return num_weeks_past_due
    else
      return nil
    end
  end

  def profile_picture_url
    if self.profile_picture.attached? and self.profile_picture.representable?
      return rails_blob_path(self.profile_picture, disposition: "attachment", only_path: true)
    else
      ActionController::Base.helpers.asset_url("missing_profile_picture.png")
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

  def active_resigned?
    self.status == "resigned" or self.status == "active"
  end
  
  def active_involuntary?
    self.status == "resigned" or self.is_involuntary == true
  end

  def pending?
    self.status == "pending"
  end

  def writeoff?
    self.status == "writeoff"
  end

  def delinquent?
    self.status == "delinquent"
  end

  def pending_dormant?
    self.insurance_status == "dormant" or self.insurance_status == "pending"
  end

  def insurance_active?
    self.insurance_status == "dormant" or self.insurance_status == "inforce" or self.insurance_status == "lapsed" or self.insurance_status == "inactive"
  end

  def active?
    self.status == "active"
  end

  def not_active?
    self.status != "active"
  end

  def inforce_insurance_status?
    self.insurance_status == "inforce"
  end

  def lapsed_insurance_status?
    self.insurance_status == "lapsed"
  end

  def dormant_insurance_status?
    self.insurance_status == "dormant"
  end

  def resigned_insurance_status?
    self.insurance_status == "resigned"
  end

  def pending_insurance_status?
    self.insurance_status == "pending"
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
      if Settings.try(:use_recognition_date) == true and self.recognition_date.present? and !self.reinstated.present?
        self.recognition_date.strftime("%b %d, %Y")
      elsif Settings.try(:use_recognition_date) == true and self.recognition_date.present? and self.reinstated.present?
        self.old_recognition_date.strftime("%b %d, %Y")
      else
        ""
      end
    end
  end

  def is_reinstated?
    if self.data.with_indifferent_access[:reinstatement].present?
      self.data.with_indifferent_access[:reinstatement][:is_reinstated] == true
    else
      false
    end
  end

  def reinstated
    if self.data.with_indifferent_access[:reinstatement].present?
      self.data.with_indifferent_access[:reinstatement][:is_reinstated] == true
    else
      false
    end
  end


  def resignation_records
    if self.data.with_indifferent_access[:resignation_records].blank?
      []
    else
      self.data.with_indifferent_access[:resignation_records]
    end
  end

  def restoration_records
    if self.data.with_indifferent_access[:restoration_records].blank?
      []
    else
      self.data.with_indifferent_access[:restoration_records]
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
      if self.status.blank?
        self.status = "pending"
      end

      self.insurance_status = "pending"

      if self.data.with_indifferent_access[:recognition_date].present?
        self.status = "active"
        self.insurance_status = "dormant"
      end
    end

    self.first_name   = self.first_name.try(:upcase)
    self.last_name    = self.last_name.try(:upcase)
    self.middle_name  = self.middle_name.try(:upcase)

    self.username = self.identification_number

    if self.encrypted_password.blank?
      self.password               = "password"
      self.password_confirmation  = "password"
    end

    # Patch for membership_type --> member_type
    if self.membership_type.present?
      self.member_type = self.membership_type.name
    end
  end

  def equity_value
    self.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").sum(:balance) / 2
  end

  def lif_amount
    self.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").sum(:balance)
  end

  def rf_amount
    self.member_accounts.where(account_type: "INSURANCE", account_subtype: "Retirement Fund").sum(:balance)
  end

  def length_of_stay_report
    self.data.with_indifferent_access[:recognition_date].present?
      now = Time.now

      if (now.to_date - self.data.with_indifferent_access[:recognition_date].to_date).to_i < 0
        number_of_days = (now.to_date - self.data.with_indifferent_access[:recognition_date].to_date).to_i
        "#{number_of_days} DAYS"
      else
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

  def length_of_stay
    if self.data.with_indifferent_access[:reinstatement].present? && self.data.with_indifferent_access[:reinstatement][:date_stop].present?
      now = Time.now

      if (now.to_date - self.data.with_indifferent_access[:reinstatement][:reinstatement_date].to_date).to_i < 0
        number_of_days = (now.to_date - self.data.with_indifferent_access[:reinstatement][:reinstatement_date].to_date).to_i + (self.data.with_indifferent_access[:reinstatement][:date_stop].to_date - self.data.with_indifferent_access[:reinstatement][:old_recognition_date].to_date).to_i
        "#{number_of_days} DAYS"

      else
        # seconds_between = (now.to_time - self.data.with_indifferent_access[:reinstatement][:reinstatement_date].to_time).abs + (self.data.with_indifferent_access[:reinstatement][:date_stop].to_time - self.data.with_indifferent_access[:reinstatement][:old_recognition_date].to_time).abs
        seconds_between = (now.to_time - self.data.with_indifferent_access[:reinstatement][:reinstatement_date].to_time).abs

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

    elsif self.data.with_indifferent_access[:recognition_date].present?
      now = Time.now

      if (now.to_date - self.data.with_indifferent_access[:recognition_date].to_date).to_i < 0
        number_of_days = (now.to_date - self.data.with_indifferent_access[:recognition_date].to_date).to_i
        "#{number_of_days} DAYS"
      else
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

  def generate_jwt
    logger.info("Using Rails.application.secret_key_base")
    JWT.encode({
      id: id,
      exp: 60.days.from_now.to_i
    }, Rails.application.secret_key_base)
  end

  def full_name_middle_initial
    if self.middle_name == ""
      "#{last_name.titleize}, #{first_name.titleize}"
    else
      "#{last_name.titleize}, #{first_name.titleize} #{middle_name[0].try(:titleize)}."
    end
  end

  def to_v2_hash
    data = self.data.with_indifferent_access

    if !data[:resignation].nil?
      r_type = data[:resignation][:type]
      r_code = data[:resignation][:code]
      r_reason = data[:resignation][:reason]
      r_accounting_reference_number = data[:resignation][:accounting_reference_number]
    else
      r_type = nil
      r_code = nil
      r_reason = nil
      r_accounting_reference_number = nil
    end

    {
      id: self.id,
      center_id: self.center.id,
      branch_id: self.branch.id,
      first_name: self.first_name,
      middle_name: self.middle_name,
      last_name: self.last_name,
      gender: self.gender,
      date_of_birth: self.date_of_birth,
      civil_status: self.civil_status,
      home_number: self.home_number,
      mobile_number: self.mobile_number,
      processed_by: self.processed_by,
      approved_by: self.approved_by,
      identification_number: self.identification_number,
      place_of_birth: self.place_of_birth,
      status: self.status,
      member_type: self.member_type,
      religion: self.religion.to_s,
      insurance_status: self.insurance_status,
      data: {
        address: {
          street: data[:address][:street],
          district: data[:address][:district],
          city: data[:address][:city]
        },
        spouse: {
          first_name: data[:spouse][:first_name],
          middle_name: data[:spouse][:middle_name],
          last_name: data[:spouse][:last_name],
          date_of_birth: data[:spouse][:date_of_birth],
          occupation: data[:spouse][:occupation]
        },
        government_identification_numbers: {
          sss_number: data[:government_identification_numbers][:sss_number],
          pag_ibig_number: data[:government_identification_numbers][:pag_ibig_number],
          phil_health_number: data[:government_identification_numbers][:phil_health_number],
          tin_number: data[:government_identification_numbers][:tin_number]
        },
        num_children_elementary: data[:num_children_elementary] || 0,
        num_children_high_school: data[:num_children_high_school] || 0,
        num_children_college: data[:num_children_college] || 0,
        num_children: data[:num_children] || 0,
        reason_for_joining: data[:reason_for_joining],
        housing: {
          type: data[:housing][:type],
          num_months: data[:housing][:num_months],
          num_years: data[:housing][:num_years],
          proof: data[:housing][:proof]
        },
        resignation: {
          type: r_type,
          code: r_code,
          reason: r_reason,
          accounting_reference_number: r_accounting_reference_number
        },
        is_experienced_with_microfinance: data[:is_experienced_with_microfinance],
        recognition_date: data[:recognition_date]
      },
      date_resigned: self.date_resigned,
      insurance_date_resigned: self.insurance_date_resigned,
      meta: self.meta,
      external_ref: self.external_ref
    }
  end

  def user_object
    {
      id: id,
      username: username,
      email: email,
      first_name: first_name,
      last_name: last_name,
      full_name: full_name,
      identification_number: identification_number
    }
  end

  def to_h
    user_object
  end

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
