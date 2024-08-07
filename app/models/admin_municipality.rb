class AdminMunicipality < ApplicationRecord
    belongs_to :admin_province, foreign_key: :province_id, primary_key: :id
    has_many :admin_barangays, foreign_key: :municipality_id, primary_key: :id

    # delegate :region_name, :province_name, to: :admin_province, prefix: true
    # delegate :admin_address_region_name, to: :admin_province, prefix: true

    delegate :province_name, :admin_address_region_name, to: :admin_province, prefix: true

    validates :admin_province, presence: true

    # delegate :region_name, :province_name, to: :admin_province, prefix: true
    
end
