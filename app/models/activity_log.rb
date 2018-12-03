class ActivityLog < ApplicationRecord
  ACTIVITY_TYPES  = [
    "approval",
    "display",
    "deletion",
    "correction",
    "modification",
    "create",
    "delete"
  ]

  validates :content, presence: true
end
