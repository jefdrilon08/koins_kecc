module Administration
  module AdministrationAddress 
    class ImportAdminAddressFromCsvFile
      
      def initialize(file:, user:)
        @file = file
        @user = user
      end

      def execute!
        load_csv_file!
      end

      private

      def load_csv_file!
        CSV.foreach(@file.path, headers: true) do |row|
        id = row['id']

        if !id.nil?
          admin_address_record = AdminAddress.where(id: id).first

          if admin_address_record.nil?
            admin_address = AdminAddress.new

            if id.present?
              admin_address.id = uuid
            end

            admin_address.id = row['id']
            admin_address.region_name = row['region_name']
            admin_address.province_name = row['province_name']
            admin_address.is_active = row['is_active']
            admin_address.save!
          else
           
            admin_address_record.update!( 
                                      id: row['id'],
                                      region_name: row['region_name'],
                                      province_name: row['province_name'],
                                      is_active: row['is_active']
                                    )
          end
        end
      end

     end  

    end
  end
end
