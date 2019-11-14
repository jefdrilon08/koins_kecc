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
        "Age",
        "Civil Status",
        "Member Type",
        "Spouse Name",
        "Spouse Age",
        "Spouse Date of Birth",
        "Address",
        "Dependent Name",
        "Dependent Age",
        "Dependent Date of Birth",
        "LIF",
        "RF"
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
            member_row  <<  member.full_name
            member_row  <<  member.status
            member_row  <<  member.insurance_status
            member_row  <<  member.date_resigned
            member_row  <<  member.center.name
            member_row  <<  member.data['recognition_date']
            member_row  <<  member.date_of_birth
            member_row  <<  member.age
            member_row  <<  member.civil_status
            member_row  <<  member.member_type
            member_row  <<  member.spouse
            member_row  <<  member.spouse_age
            member_row  <<  member.try(:spouse_date_of_birth)
            member_row  <<  member.full_address_upcase
              if member.legal_dependents.count > 0
                    valid_dependents = []
                    
                    member.legal_dependents.order("date_of_birth ASC").each do |dependent|  
                      if dependent.age <= 20
                        valid_dependents << dependent
                      end
                    end
                
                    if valid_dependents.count > 0
                      dependent_full_name = valid_dependents.first.full_name.upcase
                      dependent_date_of_birth = valid_dependents.first.date_of_birth
                      dependent_civil_status = "SINGLE"
                      dependent_gender = "MALE"
                      dependent_relationship_to_member = "CHILD"
                      dependent_age = valid_dependents.first.age
                    else
                      dependent_full_name = ""
                      dependent_date_of_birth = ""
                      dependent_civil_status = ""
                      dependent_gender = ""
                      dependent_relationship_to_member = ""
                      dependent_age = "" 
                    end
              end 


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
            member_row << dependent_full_name
            member_row << dependent_age
            member_row << dependent_date_of_birth 
            member_row << member.lif_amount
            member_row << member.rf_amount
            sheet.add_row member_row
            
          end
        end
      end

      @p
    end
  end
end
