class UserTask < ApplicationRecord
  TASK_TYPES = [
    "APPROVE_BRANCH_CLOSING"
  ]

  STATUSES = [
    "pending",
    "done"
  ]

  belongs_to :user

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :task_type, presence: true, inclusion: { in: TASK_TYPES }
end
