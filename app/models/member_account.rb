class MemberAccount < ApplicationRecord
  belongs_to :member
  belongs_to :center
  belongs_to :branch


  scope :savings, -> { joins(:member).where("account_type = ?", "SAVINGS").order("members.last_name ASC") }
  scope :insurance, -> { joins(:member).where("account_type = ?", "INSURANCE").order("members.last_name ASC") }
  scope :equities, -> { joins(:member).where("account_type = ?", "EQUITY").order("members.last_name ASC") }

  scope :time_deposits, -> { joins(:member).where("account_subtype = ?", "Time Deposit").order("members.last_name ASC") }


  def to_v2_hash
    {
      id: self.id,
      member_id: self.member_id,
      account_type: "INSURANCE",
      account_subtype: self.account_subtype,
      balance: self.balance,
      center_id: self.center_id,
      branch_id: self.branch_id,
      status: self.status,
      maintaining_balance: 0.00,
    }
  end

  def account_transactions
    AccountTransaction.where(subsidiary_id: self.id)
  end

  def savings?
    self.account_type == "SAVINGS"
  end

  def insurance?
    self.account_type == "INSURANCE"
  end

  def equity?
    self.account_type == "EQUITY"
  end

  def time_deposit?
    self.account_subtype == "Time Deposit"
  end
end
