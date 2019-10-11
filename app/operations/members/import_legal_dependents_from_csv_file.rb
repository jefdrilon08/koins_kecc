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

            legal_dependent.first_name = row['first_name'].try(:upcase)
            legal_dependent.middle_name = row['middle_name'].try(:upcase)
            legal_dependent.last_name = row['last_name'].try(:upcase)
            legal_dependent.date_of_birth = row['date_of_birth']
            legal_dependent.relationship = row['relationship']
            legal_dependent.data = {
                                    is_deceased: row['is_deceased'],
                                    is_tpd: row['is_tpd'],
                                    course: row['course'],
                                    educational_attainment: row['educational_attainment']
                                    }

            member_identification_number = row['member_identification_number']
            member_uuid = row['member_uuid']
            member = Member.where(id: member_uuid).first
            member_id = member.id
            legal_dependent.member_id = member_id

            legal_dependent.save!
          else
            dependent_data = dependent_record.data.with_indifferent_access

            dependent_data[:is_deceased] = row['is_deceased']
            dependent_data[:is_tpd] = row['is_tpd']
            dependent_data[:course] = row['course']
            dependent_data[:educational_attainment] = row['educational_attainment']

            dependent_record.update!( 
                                      first_name: row['first_name'],
                                      middle_name: row['middle_name'],
                                      last_name: row['last_name'],
                                      date_of_birth: row['date_of_birth'],
                                      relationship: row['relationship'],
                                      data: dependent_data
                                    )
          end
        end  
      end
    end
  end
end
