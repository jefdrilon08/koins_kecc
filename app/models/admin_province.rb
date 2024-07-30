class AdminProvince < ApplicationRecord
    belongs_to :admin_address, foreign_key: :region_id, primary_key: :id
    has_many :admin_municipalities, foreign_key: :province_id, primary_key: :id

    delegate :region_name, to: :admin_address, prefix: true

    def province_name
        read_attribute(:province_name)
    end
end
