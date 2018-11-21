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

  validates :gender, presence: true
  validates :date_of_birth, presence: true

  validates :first_name, presence: true
  validates :middle_name, presence: true
  validates :last_name, presence: true

  validates :identification_number, presence: true, uniqueness: true, if: :active?
  validates :civil_status, presence: true
  #validates :home_number, presence: true
  #validates :mobile_number, presence: true

  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active").order("last_name ASC") }
  scope :pending, -> { where(status: "pending").order("last_name ASC") }

  before_validation :load_defaults

  def full_name
    "#{last_name}, #{first_name} #{middle_name}"
  end

  def pending?
    self.status == "pending"
  end

  def active?
    self.status == "active"
  end

  def load_defaults
    if self.new_record?
      self.status = "pending"
      self.insurance_status = "pending"
    end
  end
end
