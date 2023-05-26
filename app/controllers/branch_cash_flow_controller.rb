class BranchCashFlowController < DataStoreController
		def index
			super
			@subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
		end
		def show
		end
	end
