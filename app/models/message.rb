class Message < ApplicationRecord
  STATUSES = [
    "unread",
    "read",
    "deleted"
  ]

  belongs_to :member
  belongs_to :message, optional: true

  validates :content, presence: true
end
