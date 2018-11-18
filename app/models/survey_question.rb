class SurveyQuestion < ApplicationRecord
  QUESTION_TYPES = [
    "options", "free_text"
  ]

  belongs_to :survey

  validates :content, presence: true
  validates :question_type, presence: true, inclusion: { in: QUESTION_TYPES }
  validates :priority, presence: true, numericality: true

  def to_s
    content
  end
end
