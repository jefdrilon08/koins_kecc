class DwBranchActiveLoanCount < ApplicationRecord
  belongs_to :branch
  belongs_to :cluster
  belongs_to :area

  validates :as_of, presence: true
  validates :total, presence: true
  validates :month, presence: true
  validates :year, presence: true
end
