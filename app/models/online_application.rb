class OnlineApplication < ApplicationRecord
  STATUSES = [
    "for_verification",
    "verified",
    "processed",
    "rejected"
  ]

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :reference_number, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true
  validates :civil_status, presence: true

  belongs_to :branch, optional: true
  belongs_to :membership_type, optional: true
  belongs_to :membership_arrangement, optional: true

  before_validation :load_defaults

  has_many :online_application_documents, dependent: :destroy
  has_one_attached :profile_picture

  scope :for_verification, -> { where(status: "for_verification") }
  scope :verified, -> { where(status: "verified") }
  scope :processed, -> { where(status: "processed") }
  scope :rejected, -> { where(status: "rejected") }

  def load_defaults
    if self.status.blank?
      self.status = "for_verification"
    end

    if self.reference_number.blank?
      self.reference_number = SecureRandom.hex(4).upcase
    end
  end

  def verified?
    self.status == "verified"
  end

  def rejected?
    self.status == "rejected"
  end

  def for_verification?
    self.status == "for_verification"
  end

  def processed?
    self.status == "processed"
  end

  def age 
    if self.date_of_birth.nil?
      "Please set date of birth"
    else
      begin
        now = Time.now.utc.to_date
        now.year - self.date_of_birth.year - ((now.month > self.date_of_birth.month || (now.month == self.date_of_birth.month && now.day >= self.date_of_birth.day)) ? 0 : 1)
        #now.year - self.date_of_birth.year - (self.date_of_birth.to_date.change(:year => now.year) > now ? 1 : 0)
      rescue Exception
        "Invalid date of birth: #{self.date_of_birth}"
      end 
    end 
  end

  def full_name
    "#{last_name}, #{first_name} #{middle_name}"
  end

  def to_s
    full_name
  end
end
