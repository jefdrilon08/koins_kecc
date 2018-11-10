class Center < ApplicationRecord
  MEETING_DAYS  = [
    { value: 1, display: "MONDAY" },
    { value: 2, display: "TUESDAY" },
    { value: 3, display: "WEDNESDAY" },
    { value: 4, display: "THURSDAY" },
    { value: 5, display: "FRIDAY" }
  ]

  validates :name, presence: true
  validates :short_name, presence: true

  has_many :members

  belongs_to :branch

  def meeting_day_display
    MEETING_DAYS.each do |o|
      if self.meeting_day == o[:value]
        return o[:display]
      end
    end

    return ""
  end

  def to_s
    name
  end
end
