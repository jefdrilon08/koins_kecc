class Announcement < ApplicationRecord
  belongs_to :user 

  validates :title, presence: true
  validates :content, presence: true

  def to_s
    title
  end
end
