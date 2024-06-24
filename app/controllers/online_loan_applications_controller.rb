class OnlineLoanApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index 
  @branch_details = {}
  @branch_details[:branch_data] = []
  @online_application_status = ::LoanApplication::STATUSES
  @online_applications_list  = LoanApplication.joins(:member).where(
                                  "members.branch_id IN (?)", @branches.pluck(:id)
                                )

  @branch_account = @online_applications_list.pluck(:branch_id).uniq 
  @cluster_account = Cluster.find(Branch.find(@branch_account).pluck(:cluster_id).uniq)
  
  @center_fetch = Center.find_by_id(params[:center_id])&.name if params[:center_id].present?
  

  @online_applications = @online_applications.where(branch_id: @branch.id) if @branch.present?

    Branch.find(@branch_account).each do |bd|
      tmp = { 
              branch_id: bd["id"],
              cluster_id: bd["cluster_id"],
              test:  []
            }
          
      @online_application_status.each do |a|
        status_count  =  LoanApplication.joins(:member).where(
                          "members.branch_id = ? and loan_applications.status = ?",
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
  
 
    @online_applications_test  = LoanApplication.joins(:member).where("members.branch_id is not null")
    @online_applications  = LoanApplication.joins(:member).where("members.branch_id is null and loan_applications.status = ?","pending")
                            
   
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
                              "members.branch_id = ? and loan_applications.status =?",  @branch.id, @status
                            )
  if params[:center_id].present?
  @online_applications = @online_applications.joins(member: :center).where(centers: { id: params[:center_id] })
  #raise @online_applications.count.inspect
  end
 
  if params[:date_applied].present?
    @online_applications = @online_applications.where(date_applied: params[:date_applied])
  end

  end

    @online_applications  = @online_applications
                              .order("status ASC, last_name ASC")
                              .page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items  = [
      { text: "Online Applications" }
    ]

  end

  
  def show
    @online_application       = LoanApplication.find(params[:id])
    @online_application_data = MemberAccount.where(member_id:  @online_application.member_id)
    

      @subheader_side_actions = []
      
      if @online_application.pending?
        if helpers.so_mis_user
          @subheader_side_actions << {
            id: "btn-for-review",
            class: "fa fa-pencil-alt", 
            link: "#",
            data: { id: @online_application.id },
            text: "For Review"
          }
        end
      end



      if @online_application.status == "for_review"
        if helpers.so_mis_user
          @subheader_side_actions << {
            id: "",
            class: "fa fa-pencil-alt",
            link: edit_online_loan_application_path(@online_application.id),
            text: "Edit"
          }
          @subheader_side_actions << {
            id: "btn-for-approve",
            class: "fa fa-pencil-alt",
            link: "#",
            data: { id: @online_application.id },
            text: "For Approval"
          }
        @subheader_side_actions << {
          id: "btn-download-form",
          class: "fa fa-download",
          link: "#",
          text: "Download Form", data: {id: @online_application.id}
        }
          @subheader_side_actions << {
            id: "btn-reject-checking",
            class: "fa fa-pencil-alt",
            link: "#",
            data: { id: @online_application.id },
            text: "Reject"
          }
        end
      elsif @online_application.status == "for_approve"
        
        if helpers.is_mis_fm?
          @subheader_side_actions << {
            id: "btn-approve",
            class: "fa fa-pencil-alt",
            link: "#",
            data: { id: @online_application.id },
            text: "Approve"
          }
          @subheader_side_actions << {
            id: "btn-reject-approve",
            class: "fa fa-pencil-alt",
            link: "#",
            data: { id: @online_application.id },
            text: "Decline"
          }
          @subheader_side_actions << {
            id: "btn-decline",
            class: "fa fa-pencil-alt",
            link: "#",
            data: { id: @online_application.id },
            text: "Reject"
          }
        end
       
      end
    end
    
    def edit

      @online_loan_application       = LoanApplication.find(params[:id])
      

    end

    def show_details
      raise "jef".inspect
    end

  
end
