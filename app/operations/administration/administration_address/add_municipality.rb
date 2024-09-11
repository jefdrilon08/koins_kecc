module Administration
    module AdministrationAddress
        class AddMunicipality
            def initialize(config:)
                @config = config
                @municipality_name = @config[:municipality_name]
                @municipalityid = @config[:municipalityid]
                @province_id = @config[:province_id]
                Rails.logger.info "Config in service object: #{@config.inspect}"
            end

            def execute!
                if @municipalityid.blank?
                    create_municipality
                else
                    update_municipality
                end
            end

            def create_municipality
                admin_municipality = AdminMunicipality.new(
                    municipality_name: @municipality_name,
                    province_id: @province_id,
                    data: {}
                )
                admin_municipality.save!
                admin_municipality
            end
            
            def update_municipality
                admin_municipality = AdminMunicipality.find(@municipalityid)
                attributes_to_update = { municipality_name: @municipality_name }
                attributes_to_update[:province_id] = @province_id if @province_id.present?
                # admin_municipality.update!(municipality_name: @municipality_name, province_id: @province_id)
                admin_municipality.update!(attributes_to_update)
                admin_municipality
            rescue ActiveRecord::RecordNotFound
                raise "AdminAddress with provinceid #{@provinceid} not found"
            end
        
        end
    end
end