module Administration
    module AdministrationAddress 
      class ValidateAdminAddressFromCsvFile < AppValidator
        def initialize(row:)
          super()
            @row                  = row
            @id                   = row['id']
            @region_name          = row['region_name']
            @province_name        = row['province_name']
            @is_active            = row['is_active']
        end

        def execute!
          check_config!
          @errors
        end

        private

        def check_config!
          if @region_name.nil?
            @errors[:messages] << {
              key: "region_name",
              message: "Region Name is empty "
            }
          end
        end
      end
    end
end
