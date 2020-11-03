class MemberAccount < ApplicationRecord
  belongs_to :member
  belongs_to :center
  belongs_to :branch


  scope :savings, -> { joins(:member).where("account_type = ?", "SAVINGS").order("members.last_name ASC") }
  scope :insurance, -> { joins(:member).where("account_type = ?", "INSURANCE").order("members.last_name ASC") }
  scope :equities, -> { joins(:member).where("account_type = ?", "EQUITY").order("members.last_name ASC") }

  scope :time_deposits, -> { joins(:member).where("account_subtype = ?", "Time Deposit").order("members.last_name ASC") }


  def to_hash
    {
      id: self.uuid,
      member_id: self.member.uuid,
      account_type: "INSURANCE",
      account_subtype: self.insurance_type.to_s,
      balance: self.balance,
      center_id: self.member.center.uuid,
      branch_id: self.member.branch.uuid,
      status: self.status,
      maintaining_balance: 0.00
    }
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
