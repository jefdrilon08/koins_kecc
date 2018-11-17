class Survey < ApplicationRecord
  STATUSES  = ["active", "inactive"]
  validates :name, presence: true, uniqueness: true
  validates :data, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :load_defaults

  scope :active, -> { where(status: "active").order("name ASC") }
  scope :inactive, -> { where(status: "inactive").order("name ASC") }

  def active?
    self.status == "active"
  end

  def inactive?
    self.status ==  "inactive"
  end

  def load_defaults
    if self.status.blank?
      self.status = "inactive"
    end
  end

  def created_by
    if self.data.with_indifferent_access[:created_by].present?
      self.data.with_indifferent_access[:created_by][:full_name]
    end
  end
end
