class MemberMoratorium < ApplicationRecord
  STATUSES = [
    "pending",
    "processing",
    "done"
  ]

  belongs_to :branch
  belongs_to :center
  belongs_to :member

  validates :date_initialized, presence: true
  validates :number_of_days, presence: true
  validates :status, presence: true, inclusion: STATUSES

  has_many :member_loan_moratoria, dependent: :destroy

  before_validation :load_defaults

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end
  end

  def pending?
    self.status == "pending"
  end

  def processing?
    self.status == "processing"
  end

  def done?
    self.status == "done"
  end
end
