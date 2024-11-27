module Print
	class BuildPrintMigs
		def initialize(migs)

			@migs = migs 	
			@migs_data= @migs[:migs]
			@branch_name = @migs_data[:data]["branch"]["name"]
			@migs_as_of  = @migs_data[:data]["migs_as_of"]
			Rails.logger.debug "migs_data: #{@branch_name.inspect}"
      		Rails.logger.debug "migs_data: #{@migs_as_of.inspect}"
		end 

		def execute!
			@data={
				branch_name: @branch_name,
				migs_as_of:  @migs_as_of,
				records: []
			}
			@data[:records] = @migs_data[:data]["records"].map { |o|
				temp= {
				last_name: o.fetch("last_name"), 
				first_name: o.fetch("first_name"),
				middle_name: o.fetch("middle_name"),
				identification_number: o.fetch("identification_number"),
				center_name: o["center"]["name"]
				}
				temp
			} 
	
			@data[:records]= @data[:records].sort_by { |hash|hash[:center_name]}

			@data
		end
	end
end