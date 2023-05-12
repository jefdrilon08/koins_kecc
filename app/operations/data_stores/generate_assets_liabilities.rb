module DataStores
	class GenerateAssetsLiabilities
		attr_accessor :data, :result

		def initialize(config:)
			@data_store = DataStore.find(config[:data_store])
			@user = User.find(config[:user])
			@branch_accounting_codes = Settings.branch_accounting_codes
			@data = @data_store.data.with_indifferent_access
			@branches = Branch.all
		end
		
		def execute!
		
			@branch_assets_and_liabilities= @branch_accounting_codes.map { |o|
				temp = {
					branch_id:o[:branch_id],
					due_to: o[:due_to_accounting_code_id],
					due_from: o[:due_from_accounting_code_id]
				}	
				temp
			}
				@branch_records  = []
				@branches.each do |b|
					sql = 
					ActiveRecord::Base.connection.execute(<<-EOS).to_a
					Select accounting_entries.id as ae_id, 
						accounting_entries.date_posted as ae_date_approved, 
						accounting_entries.branch_id as ae_branch_id,
						journal_entries.accounting_code_id as je_accounting_code_id,
						journal_entries.post_type as je_post_type,
						journal_entries.amount as je_amount
						from accounting_entries as accounting_entries
						inner join journal_entries as journal_entries on journal_entries.accounting_entry_id = accounting_entries.id 
						where DATE(accounting_entries.date_posted) >= DATE('#{@data_store[:meta]["start_date"]}') and DATE(accounting_entries.date_posted) <= DATE('#{@data_store[:meta]["end_date"]}')
						and accounting_entries.branch_id = '#{b[:id]}' and accounting_entries.status = 'approved' 
						order by accounting_entries.id
						EOS


						sql.each do |res|
							@branch_assets_and_liabilities.each do |bal|

								if res["je_accounting_code_id"] == bal[:due_to]
								@branch_records << {
								branch_id: b[:id],
								accounting_code_id: res["je_accounting_code_id"],
								accounting_code_name: AccountingCode.find(res["je_accounting_code_id"]).name,
								amount: res["je_amount"].to_f,
								post_type: res["je_post_type"]
								}

								end

								if res["je_accounting_code_id"] == bal[:due_from]
								@branch_records << {
								branch_id: b[:id],
								accounting_code_id: res["je_accounting_code_id"],
								accounting_code_name: AccountingCode.find(res["je_accounting_code_id"]).name,
								amount: res["je_amount"].to_f,
								post_type: res["je_post_type"]
								}

								end
							end
						end
						@records = @branch_records.group_by{ |item| 
							 [item[:accounting_code_id],item[:post_type]]	}.values.flat_map{|items| 
							items.first.merge(amount: items.sum{|h| h[:amount]})}
							
				end
				@branches.each do |br|	
					@temp = {
					branch_id: br[:id],
					records: []	
					}
					@records.each do |rec|
						if rec[:branch_id] == br[:id]
							@temp[:records] << {
							accounting_code_id: rec[:accounting_code_id],
							accounting_code_name: rec[:accounting_code_name],
							amount: rec[:amount],
							post_type: rec[:post_type]
							}
						end	
						
						end

					@data[:records] <<	@temp
				end

				@data[:records] = @data[:records]
				@data_store.update(data: @data,status: "done")
				@data_store
				
		end
	


	end
end