class AdminBarangay < ApplicationRecord
    belongs_to :admin_municipality, foreign_key: :municipality_id, primary_key: :id

    delegate :province_name, :municipality_name, :region_name, to: :admin_municipality, prefix: true
end
