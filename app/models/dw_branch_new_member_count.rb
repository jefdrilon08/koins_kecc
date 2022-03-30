class DwBranchNewMemberCount < ApplicationRecord
  belongs_to :branch
  belongs_to :cluster
  belongs_to :area
end
