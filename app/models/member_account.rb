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

  def clip
    self.account_subtype == "Credit Life Insurance Plan"
  end

  def hiip
    self.account_subtype == "Hospital Income Insurance Plan"
  end

  def kbente
    self.account_subtype == "K-BENTE"
  end

  def kkalinga
    self.account_subtype == "K-KALINGA"
  end

  def life
    self.account_subtype == "Life Insurance Fund"
  end
  
  def clip_active_balance
    AccountTransaction.where("subsidiary_id = ? AND data->'data'->>'maturity_date' >= ?", self.id, Date.today).sum(:amount)
  end

  def hiip_active_balance
    active_amount = 0.00

    AccountTransaction.where("subsidiary_id = ?", self.id).each do |t|
      if (Date.today - t.transacted_at.to_date).to_i < 365
        active_amount = active_amount + t.amount
      end
    end

    return active_amount
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
