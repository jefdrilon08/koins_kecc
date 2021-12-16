module DataStores
  class MemberIdGeneratorsController < DataStoreController
    def index
      @subheader_items = [
        {
          text: "Data Stores"
        },
        {
          text: "Member ID Generator"
        }
      ]

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
