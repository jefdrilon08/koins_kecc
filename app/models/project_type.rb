class ProjectType < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true

  belongs_to :project_type_category
end
