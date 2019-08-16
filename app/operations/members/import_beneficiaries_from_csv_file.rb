module Members
  class ImportBeneficiariesFromCsvFile
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
          beneficiary_record = Beneficiary.where(id: uuid).first

          if beneficiary_record.nil?
            beneficiary = Beneficiary.new

            if uuid.present?
              beneficiary.id = uuid
            end

            beneficiary.first_name = row['first_name'].try(:upcase)
            beneficiary.middle_name = row['middle_name'].try(:upcase)
            beneficiary.last_name = row['last_name'].try(:upcase)
            beneficiary.date_of_birth = row['date_of_birth']
            beneficiary.relationship = row['relationship']
            beneficiary.is_primary = row['is_primary']
            beneficiary.is_deceased = row['is_deceased']

            member_identification_number = row['member_identification_number']
            member = Member.where(identification_number: member_identification_number).first
            member_id = member.id
            beneficiary.member_id = member_id

            beneficiary.save!
          else
            beneficiary_record.update!( 
                                      first_name: row['first_name'].try(:upcase),
                                      middle_name: row['middle_name'].try(:upcase),
                                      last_name: row['last_name'].try(:upcase),
                                      date_of_birth: row['date_of_birth'],
                                      relationship: row['relationship'],
                                      is_deceased: row['is_deceased'],
                                      is_primary: row['is_primary']
                                    )
          end
        end  
      end
    end
  end
end
