class Center < ApplicationRecord
  validates :name, presence: true
  validates :short_name, presence: true

  belongs_to :branch

  def to_s
    name
  end
end
