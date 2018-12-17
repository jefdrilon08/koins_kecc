class ProjectTypeCategory < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true

  has_many :project_types
  accepts_nested_attributes_for :project_types, allow_destroy: true

  def to_s
    name
  end
end
