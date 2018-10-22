class ActivityLog < ApplicationRecord
  ACTIVITY_TYPES  = [
    "approval",
    "display",
    "correction"
  ]

  validates :content, presence: true
end
