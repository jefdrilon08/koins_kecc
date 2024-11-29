module DataStores
    class HolidayController < DataStoreController

    def index 
        @subheader_side_actions = [
            {
              id: "btn-new",
              link: "#",
              class: "fa fa-plus",
              text: "New"
            }
        ]
    end

    

end
end
