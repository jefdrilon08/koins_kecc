class Loan < ApplicationRecord
  STATUSES  = [
    "for-verification",
    "verified",
    "in-process",
    "rejected",
    "pending",
    "for-release",
    "active",
    "paid",
    "processing",
    "for-writeoff",
    "writeoff"
  ]

  belongs_to :center
  belongs_to :branch
  belongs_to :member
  belongs_to :loan_product
  belongs_to :user, optional: true
  belongs_to :project_type, optional: true
  belongs_to :loan_product_type, optional: true
  belongs_to :loan_product_taggings, optional: true

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :principal, presence: true, numericality: true
  validates :interest, presence: true, numericality: true
  validates :date_prepared, presence: true
  validates :principal_balance, presence: true, numericality: true
  validates :interest_balance, presence: true, numericality: true
  validates :principal_paid, presence: true, numericality: true
  validates :interest_paid, presence: true, numericality: true

  scope :for_verification, -> { where(status: "for-verification") }
  scope :in_process, -> { where(status: "in-process") }
  scope :for_release, -> { where(status: "for-release") }
  scope :verified, -> { where(status: "verified") }
  scope :pending, -> { where(status: "pending") }
  scope :active, -> { where(status: "active") }
  scope :paid, -> { where(status: "paid") }
  scope :active_or_paid, -> { where(status: ["active", "paid"]) }
  scope :active_or_pending, -> { where(status: ["active", "pending"]) }
  scope :writeoff, -> {where(status: "writeoff")}
  scope :for_writeoff, -> {where(status: "for-writeoff")}

  has_one_attached :application_form
  has_one_attached :co_maker_relative_profile_picture
  has_one_attached :co_maker_non_relative_profile_picture

  has_many :amortization_schedule_entries, dependent: :destroy

  before_validation :load_defaults

  def term_interval
    case self.term
    when "yearly"
      return "years"
    when "quarterly"
      return "quarters"
    when "monthly"
      return "months"
    when "semi-monthly"
      return "semi-months"
    when "weekly"
      return "weeks"
    when "daily"
      return "days"
    end
  end

  def in_process?
    self.status == "in-process"
  end

  def verified?
    self.status == "verified"
  end

  def for_verification?
    self.status == "for-verification"
  end

  def accounting_entry
    entry = data.fetch("accounting_entry")

    AccountingEntry.find_by(
      book:             entry["book"],
      reference_number: entry["reference_number"],
      particular:       entry["particular"],
    )
  end

  def is_remote?
    self.data.key?("is_remote_application")
  end

  def loan_product_name
    self.loan_product.name
  end

  def restructured?
    self.is_restructured
  end

  def load_defaults
    if self.new_record?
      if self.status.blank?
        self.status = "pending"
      end

      self.payment_type = "cash"
    end

    if self.user.blank? and self.center.present?
      self.user = self.center.user 
    end

    if self.date_approved.present? and self.date_released.blank?
      self.date_released = self.date_approved
    end

    # Insert meta information on member, branch, center, loan product
    temp_data = self.data.with_indifferent_access

    # member
    if member.present?
      temp_data[:member] = {
        first_name: member.first_name,
        middle_name: member.middle_name,
        last_name:    member.last_name
      }

      temp_data[:member_full_name] = member.full_name
    end

    if branch.present?
      temp_data[:branch_name] = branch.name
    end

    if center.present?
      temp_data[:center_name] = center.name
    end

    if loan_product.present?
      temp_data[:loan_product_name] = loan_product.name
    end

    self.data = temp_data
  end

  def has_co_maker_one?
    temp_data = self.data.with_indifferent_access

    temp_data[:co_maker_one].present? and temp_data[:co_maker_one][:id].present?
  end

  def co_maker_one
    temp_data = self.data.with_indifferent_access

    if temp_data[:co_maker_one].present?
      "#{temp_data[:co_maker_one][:last_name]}, #{temp_data[:co_maker_one][:first_name]} #{temp_data[:co_maker_one][:middle_name]}"
    end
  end

  def co_maker_two
    temp_data = self.data.with_indifferent_access

    # temp_data[:co_maker_two]
  end

  def co_maker_three
    temp_data = self.data.with_indifferent_access

    # temp_data[:co_maker_three]
  end

  def total_balance
    self.principal_balance + self.interest_balance
  end

  def total_dues
    self.principal + self.interest
  end

  def num_weeks
#    start_date  = self.amortization_schedule_entries.order("due_date ASC").first.due_date
#    end_date    = self.amortization_schedule_entries.order("due_date ASC").last.due_date

#    if start_date.present? and end_date.present?
#      ((end_date - start_date ) / 7).to_i
#    else
#      0
#    end
    num_installments
  end

  def total_paid
    self.principal_paid + self.interest_paid
  end

  def active_or_paid?
    ["active", "paid"].include?(self.status)
  end

  # Insurance CLIP related information
  def clip_number
    temp  = self.data.with_indifferent_access

    temp[:clip_number]
  end

  def beneficiary_first_name
    temp  = self.data.with_indifferent_access

    if temp[:clip_beneficiary] and temp[:clip_beneficiary][:first_name]
      temp[:clip_beneficiary] and temp[:clip_beneficiary][:first_name]
    end
  end

  def beneficiary_middle_name
    temp  = self.data.with_indifferent_access

    if temp[:clip_beneficiary] and temp[:clip_beneficiary][:middle_name]
      temp[:clip_beneficiary] and temp[:clip_beneficiary][:middle_name]
    end
  end

  def beneficiary_last_name
    temp  = self.data.with_indifferent_access

    if temp[:clip_beneficiary] and temp[:clip_beneficiary][:last_name]
      temp[:clip_beneficiary] and temp[:clip_beneficiary][:last_name]
    end
  end

  def beneficiary_relationship
    temp  = self.data.with_indifferent_access

    if temp[:clip_beneficiary] and temp[:clip_beneficiary][:relationship]
      temp[:clip_beneficiary] and temp[:clip_beneficiary][:relationship]
    end
  end

  def beneficiary_date_of_birth
    temp  = self.data.with_indifferent_access

    if temp[:clip_beneficiary] and temp[:clip_beneficiary][:date_of_birth].present?
      temp[:clip_beneficiary] and temp[:clip_beneficiary][:date_of_birth].to_date.strftime("%b %d, %Y")
    end
  end

  def voucher_bank_check_number
    temp  = self.data.with_indifferent_access[:voucher]

    temp[:bank_check_number]
  end

  def voucher_check_voucher_number
    temp  = self.data.with_indifferent_access[:voucher]

    temp[:check_number]
  end

  def voucher_date_requested
    temp  = self.data.with_indifferent_access[:voucher]

    if temp[:date_requested]
      temp[:date_requested].to_date.strftime("%b %d, %Y")
    end
  end

  def voucher_date_of_check
    temp  = self.data.with_indifferent_access[:voucher]

    if temp[:date_of_check].present?
      temp[:date_of_check].to_date.strftime("%b %d, %Y")
    end
  end

  def voucher_particular
    temp  = self.data.with_indifferent_access[:voucher]

    temp[:particular]
  end

  def pending?
    self.status == "pending"
  end

  def paid?
    self.status == "paid"
  end

  def active? 
    self.status == "active"
  end

  def writeoff?
    self.status == "writeoff"
  end
end
