module DataStores
    class DormantController < DataStoreController
        def index
            @subheader_side_actions = [
                {
                    id: "btn-new",
                    link: "#",
                    class: "fa fa-plus",
                    text: "New"
                }
            ]
            branch_id = params[:branch_id]
            as_of_date = params[:date]
            @dormants = DataStore.where("meta ->> ? = ?", 'data_store_type', 'DORMANT')
        end

        def show
            @data_store = DataStore.find(params[:id])
            @data = @data_store.data.with_indifferent_access

            @accounting_entry = @data[:accounting_entry]
        end
    end
end