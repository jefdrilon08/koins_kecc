module DataStores
	class ShareCapitalSummaryController < DataStoreController
		def index


			@share_capital_summary = DataStore.where("meta ->> 'branch_id' IN (?) AND 
							    meta ->> 'data_store_type' = 'SHARE_CAPITAL_SUMMARY'", @branches.pluck(:id)).page(params[:page]).per(20)

			if params[:start_date].present?
			@share_capital_summary = @share_capital_summary.where("as_of = ?" , params[:start_date])
			end

			@branch_id = params[:branch_id] 
			if @branch_id.present?
					@share_capital_summary = @share_capital_summary.where("meta->>'branch_id' = ?", @branch_id)
			end
            
			@subheader_side_actions = [{ 
 			text: "Generate New", 
 			link: "#", 
 			class: "fa fa-plus", 
 			id: "btn-new"}]		
			
			 @subheader_items = [
        {
          is_link: true,
          path: " /data_stores/share_capital_summary",
          text: "share capital"
        }
      ]
		end
		def show
			super

			@payload = {
        id: @record.id
      }
		end
	end
end
