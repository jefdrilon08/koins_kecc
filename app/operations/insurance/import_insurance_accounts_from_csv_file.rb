module Insurance
  class ImportInsuranceAccountsFromCsvFile
    def initialize(file:)
      @file = file
    end

    def execute!
      load_csv_file!
    end

    private

    def load_csv_file!
      CSV.foreach(@file.path, headers: true) do |row|
        member_id = row['member_id']
        member_uuid = row['member_uuid']
        member = Member.where(id: member_uuid).first

        if row['insurance_type'] == "LIF"
          acc_subtype = "Life Insurance Fund"
        elsif  row['insurance_type'] == "RF"
          acc_subtype = "Retirement Fund"
        elsif  row['insurance_type'] == "CLIP"
          acc_subtype = "Credit Life Insurance Plan"
        elsif  row['insurance_type'] == "HIIP"
          acc_subtype = "Hospital Income Insurance Plan"
        elsif  row['insurance_type'] == "PL"
          acc_subtype = "Policy Loan"    
        end

        if !member.nil?
          insurance_account = member.member_accounts.where(account_subtype: acc_subtype).first
          if insurance_account.present?
            if row['equity_value'].nil?
              insurance_account.update!(
                id: row['uuid'],
                status: row['status']
              )
            else
              ia_data = insurance_account.data
         
              if !ia_data.nil?
                ia_data[:equity_value] = row['equity_value']

                insurance_account.update!(
                  id: row['uuid'],
                  status: row['status'],
                  data: ia_data
                )
              end
            end
          else
            new_insurance_account = MemberAccount.new

            if !row['uuid'].nil?
              new_insurance_account.id = row['uuid']
            end

            new_insurance_account.member = member
            new_insurance_account.balance = 0.00
            new_insurance_account.account_type = "INSURANCE"
            new_insurance_account.account_subtype = acc_subtype
            new_insurance_account.status = row['status']
            new_insurance_account.branch = member.branch
            new_insurance_account.center = member.center
            new_insurance_account.data = { equity_value: row['equity_value'] }

            new_insurance_account.save!
          end
        end       
      end
    end
  end
end
