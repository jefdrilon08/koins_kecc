module Members
	class GenerateInsuranceExitAgeReportExcel
		def initialize(members:)
	      @members  = members
	      @p        = Axlsx::Package.new
	    end

	    def execute!
	      	@p.workbook do |wb|
	        	wb.add_worksheet do |sheet|
		          header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
		          sheet.add_row [
		            "Full Name", 
		            "Member Type",
		            "Date of Birth",
		            "Age",
		            "Branch",
		            "Center",
		            "LIF",
		            "RF"
		          ], style: header

	          	@members.each do |member|
	            
	                sheet.add_row [
	                  member.full_name,
	                  member.member_type,
	                  member.date_of_birth,
	                  member.age,
	                  member.branch.name,
	                  member.center.name,
	                  member.member_accounts.where("account_subtype = ? AND balance >= ? ", "Life Insurance Fund", 1 ).first.try(:balance),
	                  member.member_accounts.where("account_subtype = ? AND balance >= ? ", "Retirement Fund", 1).first.try(:balance)
	                ]
	              	end
	            end
	        end
	        @p
	    end
	end
end
