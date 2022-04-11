class DwBranchMemberCount < ApplicationRecord
  belongs_to :branch
  belongs_to :cluster
  belongs_to :area

  validates :as_of, presence: true
end
