class ReadOnlyMember < Branch
  establish_connection(ENV['FOLLOWER_READ_ONLY_DATABASE_URL'])

  scope :active, -> { where(status: "active").order("last_name ASC") }
  scope :pending, -> { where(status: "pending").order("last_name ASC") }
  scope :resigned, -> { where(status: "resigned").order("last_name ASC") }
  scope :active_and_resigned, -> { where(status: ["active", "resigned"]).order("last_name ASC") }
  scope :active_and_resigned_and_pending, -> { where(status: ["active", "resigned", "pending"]).order("last_name ASC") }
  scope :returning, -> { where("status = ? AND previous_date_resigned IS NOT NULL", "active").order("last_name ASC") }
  scope :insurance_resigned, -> { where(insurance_status: "resigned").order("last_name ASC") }
  scope :insurance_active, -> { where(status: "active", insurance_status: ["inforce", "lapsed"]).order("last_name ASC") }
end
