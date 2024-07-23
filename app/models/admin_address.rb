class AdminAddress < ApplicationRecord
    has_many :admin_provinces, foreign_key: :region_id, primary_key: :id
end
