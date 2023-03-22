module DataStores
  class ProjectTypesSummaryController < DataStoreController
    def index
      
      @subheader_items = [
        {
          text: "Data Store"
        },
        {
          text: "Members For Writeoff"
        }
      ]
    end
  end
end
