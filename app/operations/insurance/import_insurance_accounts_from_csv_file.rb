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
        member = Member.find(member_id)

        if !member.nil?
          insurance_account = MemberAccount.where(id: row['uuid']).first
          
          if !insurance_account.nil?
            if row['data'].present?
              ia_data = JSON.parse(row['data'])
            else
              ia_data = nil
            end

            insurance_account.update!(

              member_id: row['member_id'],
              account_type: row['account_type'],
              account_subtype: row['account_subtype'],
              balance: row['balance'],
              center: row['center_id'],
              branch: row['branch_id'],
              status: row['status'],
              maintaining_balance: row['maintaining_balance'],
              created_at: row['created_at'],
              updated_at: row['updated_at'],
              data: ia_data
            )
          else
            new_insurance_account = MemberAccount.new
            
            if row['data'].present?
              ia_data = JSON.parse(row['data'])
            else
              ia_data = nil
            end

            if !row['uuid'].nil?
              new_insurance_account.id = row['uuid']
            end

            new_insurance_account.member = member
            new_insurance_account.account_type = row['account_type']
            new_insurance_account.account_subtype = row['account_subtype']
            new_insurance_account.balance = row['balance']
            new_insurance_account.center = member.center
            new_insurance_account.branch = member.branch
            new_insurance_account.status = row['status']
            new_insurance_account.maintaining_balance = row['maintaining_balance']
            new_insurance_account.created_at = row['created_at']
            new_insurance_account.updated_at = row['updated_at']
            new_insurance_account.data = ia_data

            new_insurance_account.save!
          end
        end       
      end
    end
  end
end
