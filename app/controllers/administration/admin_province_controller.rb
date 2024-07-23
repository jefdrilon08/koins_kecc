module Administration
    class AdminProvinceController < ApplicationController
        before_action :authenticate_user!

        def index
            @subheader_side_actions = [
                {
                    id: "btn-new",
                    link: "#",
                    class: "fa fa-plus",
                    text: "New Province"
                }
            ]
            @admin_index_list = AdminProvince.joins(:admin_address).order('admin_addresses.region_name', 'admin_provinces.province_name')
            @regions = AdminAddress.order(:region_name)
        end

        private
        
        def admin_province
            @admin_province.require(:admin_province).permit!
        end

        def admin_province_params
            params.require(:admin_province).permit!
        end
    end
end