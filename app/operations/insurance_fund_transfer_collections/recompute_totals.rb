module InsuranceFundTransferCollections
	class RecomputeTotals
		def initialize(config:)
			@config 				= config
			@data   				= @config[:data]
			@current_member			= @config[:current_member]
			@user					= @config[:user]
			@insurance_withdrawal_collection 	= @config[:insurance_withdrawal_collection]
		end

		def execute!

		  # Reset
	      @data[:totals].each_with_index do |t, index|
	        @data[:totals][index][:amount]  = 0.00
	      end

	      # Recompute
	      total_collected = 0.00

	      @data[:totals].each_with_index do |t, index|
	        if t[:record_type] == "SAVINGS"
	          @data[:records].each_with_index do |r, i|
	            r[:records].each_with_index do |rr, j|
	              if rr[:record_type] == "SAVINGS" and t[:key] == rr[:account_subtype]
	                total_collected += rr[:amount].try(:to_f).round(2)
	                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
	              end
	            end
	          end
	        elsif t[:record_type] == "INSURANCE"
	          @data[:records].each_with_index do |r, i|
	            r[:records].each_with_index do |rr, j|
	              if rr[:record_type] == "INSURANCE" and t[:key] == rr[:account_subtype]
	                total_collected += rr[:amount].try(:to_f).round(2)
	                @data[:totals][index][:amount] += rr[:amount].try(:to_f).round(2)
	              end
	            end
	          end
	        end
	      end

	      @data[:total_collected] = total_collected

	      # Recompute member totals
	      total_collected_for_member  = 0.00
	      @data[:records].each_with_index do |r, i|
	        if r[:member][:id] == @current_member[:id]
	          r[:records].each_with_index do |rr, j|
	            total_collected_for_member += rr[:amount].try(:to_f).round(2)
	          end

	          @data[:records][i][:total_collected] = total_collected_for_member
	        end
	      end
		
			@data		
		end
	end
end