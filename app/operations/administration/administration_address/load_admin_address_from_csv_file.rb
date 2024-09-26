module Administration
    module AdministrationAddress 
      class LoadAdminAddressFromCsvFile
        def initialize(config:)
          @config               = config
          @file                 = @config[:file]
        end

        def execute!
          CSV.foreach(@file.path, headers: true) do |row|
            @id                   = row['id']
            @region_name          = row['region_name']
            @province_name        = row['province_name']
            @is_active            = row['is_active']


            @admin_address = ::Administration::AdministrationAddress::CreateAdminAddress.new(
              config: {
                id: @id,
                region_name: @region_name,
                province_name: @province_name,
                is_active: @is_active
              }
            ).execute!

          end
        end
      end
    end
end
