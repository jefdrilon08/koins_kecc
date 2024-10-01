module Administration
    module AdministrationAddress 
        class AddRegion 
            def initialize(config:)
                @config = config
                @region_name = @config[:region_name]
                @regionid = @config[:regionid]
            end

            def execute!
                if @regionid.blank?
                    create_region
                else
                    update_region
                end
            end

            private

            def create_region
                admin_address = AdminAddress.new(
                    region_name: @region_name,
                    data: {
                        province: []
                    }
                )
                admin_address.save!
                admin_address
            end

            def update_region
                admin_address = AdminAddress.find(@regionid)
                admin_address.update!(region_name: @region_name)
                admin_address
            rescue ActiveRecord::RecordNotFound
                raise "AdminAddress with regionid #{@regionid} not found"
            end

        end
    end
end
