class ActivityLog < ApplicationRecord
  ACTIVITY_TYPES  = [
    "approval",
    "display",
    "correction",
    "modification"
  ]

  validates :content, presence: true
end
