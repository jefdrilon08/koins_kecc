module Administration
    class AdminBarangayController < ApplicationController
    before_action :authenticate_user!
        
    def index
        @subheader_side_actions = [
            {
                id: "btn-new",
                link: '#',
                class: "fa fa-plus",
                text: "New Barangay"
            }
        ]
        @admin_barangay_list = AdminBarangay.joins(:admin_municipality).order('admin_municipalities.municipality_name', 'admin_barangays.barangay_name')
        @municipalities = AdminMunicipality.order(:municipality_name)
    end

    private
    def admin_barangay
        @admin_barangay.require(:admin_barangay).permit!
    end

    def admin_barangay_params
        params.require(:admin_barangay).permit!
    end


    end 
end