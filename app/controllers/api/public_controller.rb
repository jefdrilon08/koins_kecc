module Api
  class PublicController < ActionController::API
    def branches
      branches  = Branch.select("id, name").order("name ASC").map{ |o|
                    {
                      id: o.id,
                      name: o.name
                    }
                  }

      render json: { branches: branches }
    end

    def centers
      if params[:branch_id].blank?
        render json: { errors: { branch_id: 'Branch id required' } }, status: :unprocessable_entity
      else
        centers = Center.select("id, name, branch_id").order("name ASC").map{ |o|
                    {
                      id: o.id,
                      name: o.name,
                      branch_id: o.branch_id
                    }
                  }

        render json: { centers: centers }
      end
    end

    def status_check
      reference_number = params[:reference_number]

      if reference_number.blank?
        render json: { errors: ["reference_number required"] }, status: :not_found
      else
        online_application = OnlineApplication.find_by_reference_number(reference_number)

        if online_application.blank?
          render json: { errors: ["online application not found"] }, status: :not_found
        else
          render json: { status: online_application.status }
        end
      end
    end
  end
end
