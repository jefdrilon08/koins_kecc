class ActivityLog < ApplicationRecord
  ACTIVITY_TYPES  = [
    "approval",
    "display",
    "deletion",
    "correction",
    "modification"
  ]

  validates :content, presence: true
end
