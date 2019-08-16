module Members
  class GenerateMembersPerBranchExcel
    def initialize(members:, branch:)
      @members           = members
      @branch            = branch
      @p                 = Axlsx::Package.new
      @header_labels  = [
        "ID Number",
        "Name",
        "Status",
        "Insurance Status",
        "Insurance Date Resigned",
        "Center",
        "Recognition Date",
        "Date of Birth",
        # "LIF",
        # "RF",
      ]
    end

    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          if @branch.present?
            sheet.add_row ["Members list from #{@branch.to_s}"]
          end

          # Headers
          sheet.add_row @header_labels

          @members.each do |member|
            
            member_row  = []
            member_row  <<  member.identification_number
            member_row  <<  member.full_name_middle_initial
            member_row  <<  member.status
            member_row  <<  member.insurance_status
            member_row  <<  member.date_resigned
            member_row  <<  member.center
            member_row  <<  member.data['recognition_date']
            member_row  <<  member.date_of_birth

            # InsuranceType.all.order("name ASC").each do |insurance_type|
            #   fund = 0.00
            #     # latest_transaction = member.insurance_accounts.where(insurance_type_id: insurance_type.id, member_id: member.id).first.insurance_account_transactions.approved.where("date(created_at) <= ?", @as_of).order("id ASC").last
            #     insurance_account = member.insurance_accounts.where(insurance_type_id: insurance_type.id, member_id: member.id).first
            #     if !insurance_account.insurance_account_transactions.approved.last.nil?                 
            #       latest_transaction = insurance_account.insurance_account_transactions.approved.last
            #       balance = latest_transaction.try(:ending_balance)
            #         if !balance
            #         balance = 0.00
            #       end
            #     end

            #   fund += balance.to_i
            #   member_row << fund
            # end
            
            sheet.add_row member_row
          end
        end
      end

      @p
    end
  end
end
