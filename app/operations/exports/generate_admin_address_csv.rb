module Exports
  class GenerateAdminAddressCsv
    def initialize(admin_address:)
      @admin_address = admin_address
    end
    
    def execute!
      CSV.generate do |csv|
        csv << [
          :id,
          :region_name, 
          :province_name, 
          :is_active
        ]

        @admin_address.find_in_batches(batch_size: 1000) do |group|
          group.each do |admin_add|
            csv << [
              admin_add.id,
              admin_add.region_name,
              admin_add.province_name,
              admin_add.is_active,
            ]
          
          end
        end
      end
    end
  end
end