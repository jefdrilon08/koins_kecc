module Print
	class BuildMonthlyIncentive
		def initialize(config)
			@data_id = config[:config]
			@data_store= DataStore.find(@data_id)
			@data_record= @data_store.data.with_indifferent_access
			@cluster_id = Branch.find(@data_store.meta["branch_id"]).cluster_id
			@cluster = Cluster.find(@cluster_id)
		end

		def execute!
			@branch_user = UserBranch.where(branch_id: @data_store.meta["branch_id"],active: true).pluck(:user_id)
			
			@branch_user.each do |branch_users|
				user = User.find(branch_users)

				if user.current_roles.shift == "FM"
					@som = user[:first_name] + " "+ user[:last_name]
				end

				if user.current_roles.shift == "BK"
					@acco = user[:first_name] + " "+ user[:last_name]
				end

			end
			
			@data = {
				branch_id: @data_store.meta["branch_id"],
				branch_name: @data_store.meta["branch_name"],
				cluster_name: @cluster.name,
				incentive_data: @data_store.meta["as_of"],
				som_user: @som,
				accounting_user: @acco,
				total_so_incentive: @data_record[:total_so_incentive] || 0.00,
				average_so_incentive: @data_record[:total_average_so_incentive] || 0.00,
				total_regular_so: @data_record[:total_regular_so] || 0.00,
				som_incentive: @data_record[:som_incentive] || 0.00,
				incentive_date: @data_store.meta["as_of"].to_date.strftime("%B %d, %Y")
			}
			@data[:records] = @data_record[:records].map{ |o| 
				temp = {
					officer_name:o["officer"]["first_name"] + " "+ o["officer"]["last_name"],
					status: o["status"],
					disburment: o["disbursed_amount"],
					outreach: o["loaners"],
					repayment_rate: o["rr"],
					beg_loaners: o["beg_outreached"],
					new_members: o["new_members"],
					resigned_members: o["resigned_members"],
					drop_out: o["drop_out_rate"],
					par_amount: o["par_amount"],
					par_rate: o["par_rate"],
					prev_par_rate: o["prev_par_rate"],
					portfolio: o["portfolio"],
					incentive: o["incentive"],
					vwd: o["verbal_warning_demerits"],
					wwd: o["written_warning_demerits"],
					drop_out_dem: o["drop_out_demerits"],
					total_demerits: o["total_demerits"],
					final_incentive: o["final_incentive"] 

				}
				temp

			}

		@data
		end
	
	end
end