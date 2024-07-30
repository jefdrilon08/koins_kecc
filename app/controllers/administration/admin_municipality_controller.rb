module Administration
    class AdminMunicipalityController < ApplicationController
        before_action :authenticate_user!

        def index
            @subheader_side_actions = [
                {
                    id: "btn-new",
                    link: "#",
                    class: "fa fa-plus",
                    text: "New Municipality"
                }
            ]
            @admin_index_list = AdminMunicipality.joins(:admin_province).order('admin_provinces.province_name', 'admin_municipalities.municipality_name')
            @provinces = AdminProvince.order(:province_name)
            
        end

        private
        def admin_municipality
            @admin_municipality.require(:admin_municipality).permit!
        end

        def admin_municipality_params
            params.require(:admin_municipality).permit!
        end
    end
end