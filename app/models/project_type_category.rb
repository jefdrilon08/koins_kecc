class ProjectTypeCategory < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true

  has_many :project_types
end
