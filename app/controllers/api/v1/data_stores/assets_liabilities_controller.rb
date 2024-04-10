module Api
	module V1
		module DataStores
			class AssetsLiabilitiesController < ActionController::Base
				def create
					@data_store_type = "ASSETS_LIABILITIES"
					@start_date = params[:start_date]
					@end_date = params[:end_date]

					@record = DataStore.assets_liabilities.where("meta->>'start_date'=? and meta->>'end_date' =?","#{@start_date}","#{@end_date}")
					if @record.blank?
						@record = DataStore.create!(
							meta: {
								data_store_type: @data_store_type,
								start_date: @start_date,
								end_date: @end_date
							},
							data: {
								records: []
							}
							)

					sidekiq = {
						id: @record.id,
						data_store_type: @data_store_type,
						user_id: current_user.id
					}

					ProcessAssetsLiabilities.perform_later(sidekiq)
					render json: {message: "ok", id: @record.id}

					else
						render json: {errors: "duplicate record"}, status: 400
					end

			

				end
			end
		end
	end
end
