class OnlineApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @online_applications  = OnlineApplication
                              .select("*")
                              .includes(:branch)

    if current_user.current_roles.intersection(["MIS", "CM"]).length == 0
      @online_applications  = @online_applications.where(
                                "branch_id IN (?)",
                                @branches.pluck(:id)
                              )
    end

    @q      = params[:q]
    @status = params[:status]
    @branch = Branch.find_by_id(params[:branch_id])

    if @q.present?
      @online_applications  = @online_applications.where(
                                "upper(first_name) LIKE :q OR upper(last_name) LIKE :q OR upper(identification_number) LIKE :q",
                                q: "%#{@q.upcase}%"
                              )
    end

    if @status.present?
      @online_applications  = @online_applications.where(
                                status: @status
                              )
    end

    if @branch.present?
      @online_applications  = @online_applications.where(
                                branch_id: @branch.id
                              )
    end

    @online_applications  = @online_applications
                              .order("status ASC, last_name ASC")
                              .page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items  = [
      { text: "Online Applications" }
    ]
  end

  def show
    @online_application = OnlineApplication.find(params[:id])

    @payload = {
      id: @online_application.id,
      data: @online_application.to_json
    }

    @subheader_items  = [
      { is_link: true, path: online_applications_path, text: "Online Applications" },
      { text: "#{@online_application.last_name}, #{@online_application.first_name} #{@online_application.middle_name} (#{@online_application.reference_number})" }
    ]

    # For printing form
    @subheader_side_actions = []

    @subheader_side_actions << {
      id: "btn-download-form",
      class: "fa fa-download",
      link: "#",
      text: "Download Form"
    }
  end
end
