class OnlineApplication < ApplicationRecord
  GENDERS = [
    "Male",
    "Female",
    "Others"
  ]

  STATUSES = [
    "for_verification",
    " for_review ",
    " for_approve ",
    "pending",
    "approved",
    "verified",
    "processed",
    "rejected",
    "reject",
    "processing",
    "error"
    
  ]

  STATS = [
    "pending",
    "for_review",
    "for_approve",
    "approved",
    "reject"
  ]
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :reference_number, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true
  #validates :civil_status, presence: true

  belongs_to :branch, optional: true
  belongs_to :center, optional: true
  belongs_to :membership_type, optional: true
  belongs_to :membership_arrangement, optional: true

  before_validation :load_defaults

  has_many :online_application_documents, dependent: :destroy
  has_one_attached :profile_picture

  scope :for_verification, -> { where(status: "for_verification") }
  scope :verified, -> { where(status: "verified") }
  scope :processed, -> { where(status: "processed") }
  scope :rejected, -> { where(status: "rejected") }
  scope :processing, -> { where(status: "processing") }
  scope :error, -> { where(status: "error") }

  # Validate email only if present
  #validates :email, presence: false, uniqueness: true, if: Proc.new { |online_application| online_application.email.blank? }

  def load_defaults
    if self.status.blank?
      self.status = "for_verification"
    end

    if self.reference_number.blank?
      self.reference_number = SecureRandom.hex(4).upcase
    end
  end

  def spouse
    "#{self.data["spouse"]["last_name"]}, #{self.data["spouse"]["first_name"]} #{self.data["spouse"]["middle_name"]}"
  end

  def spouse_occupation
    "#{self.data["spouse"]["occupation"]}"
  end

  def spouse_date_of_birth
    "#{self.data["spouse"]["date_of_birth"]}"
  end

  def city
    "#{self.data["address"]["city"]}"
  end

  def province
    self.data["address"]["province"]
  end

  def error?
    self.status == "error"
  end

  def processing?
    self.status == "processing"
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
