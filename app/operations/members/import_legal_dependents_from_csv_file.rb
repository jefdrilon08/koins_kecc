module Members
  class ImportLegalDependentsFromCsvFile
    def initialize(file:)
      @file = file
    end

    def execute!
      load_csv_file!
    end

    private

    def load_csv_file!
      CSV.foreach(@file.path, headers: true) do |row|
        uuid = row['uuid']

        if !uuid.nil?
          dependent_record = LegalDependent.where(id: uuid).first

          if dependent_record.nil?
            legal_dependent = LegalDependent.new

            if uuid.present?
              legal_dependent.id = uuid
            end

            dependent_data = JSON.parse(row['data'])
            
            member_identification_number = row['member_identification_number']
            member_uuid = row['member_uuid']

            legal_dependent.first_name = row['first_name'].try(:upcase)
            legal_dependent.middle_name = row['middle_name'].try(:upcase)
            legal_dependent.last_name = row['last_name'].try(:upcase)
            legal_dependent.date_of_birth = row['date_of_birth']
            legal_dependent.relationship = row['relationship']
            legal_dependent.data = dependent_data
            legal_dependent.member_id = member_uuid

            legal_dependent.save!
          else
            dependent_data = JSON.parse(row['data'])

            dependent_record.update!( 
                                      first_name: row['first_name'],
                                      middle_name: row['middle_name'],
                                      last_name: row['last_name'],
                                      date_of_birth: row['date_of_birth'],
                                      member_id: row['member_uuid'],
                                      relationship: row['relationship'],
                                      data: dependent_data
                                    )
          end
        end  
      end
    end
  end
end
