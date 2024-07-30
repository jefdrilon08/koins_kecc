module Administration
    module AdministrationAddress
        class AddProvince 
            def initialize(config:)
                @config = config
                @province_name = @config[:province_name]
                @provinceid = @config[:provinceid]
                @region_id = @config[:region_id]
                Rails.logger.info "Config in service object: #{@config.inspect}"
            end

            def execute!
                if @provinceid.blank?
                    create_province
                else
                    update_province
                end
            end

            def create_province
                admin_province = AdminProvince.new(
                    province_name: @province_name,
                    region_id: @region_id,
                    data: {}
                )
                admin_province.save!
                admin_province
            end

            def update_province
                admin_province = AdminProvince.find(@provinceid)
                attributes_to_update = { province_name: @province_name }
                attributes_to_update[:region_id] = @region_id if @region_id.present?
                # admin_province.update!(province_name: @province_name, region_id: @region_id)
                admin_province.update!(attributes_to_update)
                admin_province
            rescue ActiveRecord::RecordNotFound
                raise "AdminAddress with provinceid #{@provinceid} not found"
            end
        end
    end
end
