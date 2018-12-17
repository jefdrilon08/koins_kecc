class ProjectType < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true

  belongs_to :project_type_category

  def to_s
    name
  end
end
