class OnlineApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @branch_details = {}
    @branch_details[:branch_data] = []
    @online_application_status = ::OnlineApplication::STATUSES
    @online_applications_list  = OnlineApplication.where(
                                                    "
                                                     branch_id IN (?)",
                                                    @branches.pluck(:id)
                                                  )

    
    @branch_account = @online_applications_list.pluck(:branch_id).uniq 
    @cluster_account = Cluster.find(Branch.find(@branch_account).pluck(:cluster_id).uniq)

  
    
    Branch.find(@branch_account).each do |bd|
      tmp = { 
              branch_id: bd["id"],
              cluster_id: bd["cluster_id"],
              test:  []
            }


      @online_application_status.each do |a|
        status_count  = OnlineApplication.where(
                          "branch_id = ? and status = ?",
                          bd["id"],
                          a

                        )

        if status_count.present?
          tmp_details = { app_status: a, total_number: status_count.count }
        else
          tmp_details = { app_status: a, total_number: 0 }
          
        end
        tmp[:test] << tmp_details
      end




      @branch_details[:branch_data] << tmp
    end
    
    @branch_details
    @online_applications_test  = OnlineApplication.where("branch_id is not null")
    @online_applications  = OnlineApplication.where("branch_id is null and status = ?","for_verification")
                            

    @q      = params[:q]
    @status = params[:status]
    @branch = Branch.find_by_id(params[:branch_id])

  


    if @q.present?
      @online_applications  = @online_applications.where(
                                "upper(first_name) LIKE :q OR upper(last_name) LIKE :q OR upper(middle_name) LIKE :q",
                                q: "%#{@q.upcase}%"
                              )
    end

    if @status.present?
      @online_applications  = @online_applications_test.where(
                                status: @status
                              )
      
    end

    if @branch.present?
      @online_applications  = @online_applications_test.where(
                                branch_id: @branch.id
                              )
    end


    if  @branch.present? and @status.present?
      @online_applications  = @online_applications_test.where(
                                branch_id: @branch.id, status: @status
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
    @online_application       = OnlineApplication.find(params[:id])

    if @online_application.processing?
      redirect_to online_applications_path(message: "online application still processing")
    else
      @membership_types         = MembershipType.all
      @membership_arrangements  = MembershipArrangement.all

      data  = ::OnlineApplications::BuildMemberFormData.new(
                online_application: @online_application
              ).execute!

      @centers = []

      if @online_application.branch_id.present?
        @centers  = ReadOnlyCenter.where(branch_id: @online_application.branch_id).order("name ASC")
      end

      @payload = {
        id: @online_application.id,
        data: data
      }

      @subheader_items  = [
        { is_link: true, path: online_applications_path, text: "Online Applications" },
        { text: "#{@online_application.last_name}, #{@online_application.first_name} #{@online_application.middle_name} (#{@online_application.reference_number})" }
      ]

      # For printing form
      @subheader_side_actions = []

      valid_roles_assign_branch = ::Users::FetchValidRoles.new(
                                    module_name: "online_application_assign_branch"
                                  ).execute!

      if current_user.current_roles.intersection(valid_roles_assign_branch).size > 0
        @subheader_side_actions << {
          id: "btn-assign-branch",
          class: "fa fa-check",
          link: "#",
          text: "Assign Satellite Office"
        }
      end

      @subheader_side_actions << {
        id: "btn-download-form",
        class: "fa fa-download",
        link: "#",
        text: "Download Form"
      }
    end
    
    def show_details
      raise "jef".inspect
    end

  end
end
