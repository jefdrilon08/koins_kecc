module Administration
    module AdministrationAddress 
      class CreateAdminAddress
        def initialize(config:)
          @config = config
          @admin_address = AdminAddress.new(
                id: config[:id],
                region_name: config[:region_name],
                province_name: config[:province_name],
                is_active: config[:is_active]
          )
        end

        def execute!
          @admin_address.save!
          @admin_address
        end
      end
    end
end
