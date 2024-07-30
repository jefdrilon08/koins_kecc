module Administration
    module AdministrationAddress
        class AddBarangay
            def initialize(config:)
                @config = config
                @barangay_name = @config[:barangay_name]
                @barangayid = @config[:barangayid]
                @municipality_id = @config[:municipality_id]
            end

            def execute!
                if @barangayid.blank?
                    create_barangay
                else
                    update_barangay
                end
            end

            def create_barangay
                admin_barangay = AdminBarangay.new(
                    barangay_name: @barangay_name,
                    municipality_id: @municipality_id,
                    data: {}
                )
                admin_barangay.save!
                admin_barangay
            end

            def update_barangay
                admin_barangay = AdminBarangay.find(@barangayid)
                attributes_to_update = { barangay_name: @barangay_name }
                attributes_to_update[:municipality_id] = @municipality_id if @municipality_id.present?
                # admin_barangay.update!(barangay_name: @barangay_name, municipality_id: @municipality_id)
                admin_barangay.update(attributes_to_update)
                admin_barangay
            end
        
        end
    end
end