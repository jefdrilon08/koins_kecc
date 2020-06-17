class ReadOnlyLoan < Branch
  establish_connection(ENV['FOLLOWER_READ_ONLY_DATABASE_URL'])

  scope :pending, -> { where(status: "pending") }
  scope :active, -> { where(status: "active") }
  scope :paid, -> { where(status: "paid") }
  scope :active_or_paid, -> { where(status: ["active", "paid"]) }
  scope :active_or_pending, -> { where(status: ["active", "pending"]) }
end
