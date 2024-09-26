class ApiReceiveMember < ApplicationRecord
  STATUSES  = [
    "pending",
    "approve"
  ]

  belongs_to :branch

  def pending?
    self.status == "pending"
  end

  def approved?
    self.status == "approve"
  end
end
