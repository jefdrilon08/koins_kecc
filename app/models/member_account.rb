class MemberAccount < ApplicationRecord
  belongs_to :member
  belongs_to :center
  belongs_to :branch


  scope :savings, -> { joins(:member).where("account_type = ?", "SAVINGS").order("members.last_name ASC") }
  scope :insurance, -> { joins(:member).where("account_type = ?", "INSURANCE").order("members.last_name ASC") }
  scope :equities, -> { joins(:member).where("account_type = ?", "EQUITY").order("members.last_name ASC") }

  def savings?
    self.account_type == "SAVINGS"
  end

  def insurance?
    self.account_type == "INSURANCE"
  end

  def equity?
    self.account_type == "EQUITY"
  end
end
