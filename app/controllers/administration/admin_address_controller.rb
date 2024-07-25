module Administration 
    class AdminAddressController < ApplicationController
        before_action :authenticate_user!

        def index
            @subheader_side_actions = [
                {
                  id: "btn-new",
                  link: '#',
                  class: "fa fa-plus",
                  text: "New Region"
                }
              ]
              @admin_address_list = AdminAddress.all.sort_by(&:region_name)
        end

        private
        
        def admin_address
          @admin_address.require(:admin_address).permit!
        end

        def admin_address_params
          params.require(:admin_address).permit!
        end
        
    end
end
