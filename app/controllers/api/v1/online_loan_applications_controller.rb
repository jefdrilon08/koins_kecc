module Api
  module V1
    class OnlineLoanApplicationsController < ApiController
      before_action :authenticate_user!

      def assign_branch
        online_application  = OnlineApplication.find(params[:id])
        data_online_application = online_application.data.with_indifferent_access
    
        approve_process = { type: "assign_branch_by", name: current_user.full_name, date_assign: Date.today  }
        
        validator = ::OnlineApplications::ValidateAssignBranch.new(
                      online_application: online_application,
                      user: current_user
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { full_messages: validator.errors[:full_messages] }, status: 403
        else
          branch = ReadOnlyBranch.find(params[:branch_id])
          data_online_application["approve_process"] = []
          data_online_application["approve_process"] << approve_process
          online_application.update!(
            branch: branch,
            data: data_online_application
          )

          render json: { message: "ok" }
        end
      end
      
      def for_review
      
        online_application  = LoanApplication.find(params[:id])
        online_application.update!(status: "for_review")
        render json: { message: "ok" }
     
      end

      def for_approve     
        online_application  = LoanApplication.find(params[:id])
        online_application.update!(status: "for_approve")
        

        render json: { message: "ok" }
     
      end
      
      def approve_loan
    
        online_application  = LoanApplication.find(params[:id])
        member = Member.find(online_application.member_id)
        member = Member.find(online_application.member_id)
        co_maker = Member.find(online_application.co_maker_member_id) 
        loan_data = {
                      id: nil,
                      branch_id: member.branch_id,
                      center_id: member.center_id,
                      date_prepared: "2024-03-01",
                      member_id: member.id,
                      principal: online_application.amount,
                      loan_product_id: online_application.loan_product_id,
                      term: online_application.term,
                      pn_number: online_application.reference_number,
                      num_installments: online_application.num_installments,
                      status: "pending",
                      data: {
                              voucher:{
                                        bank:"",
                                        bank_check_number: "",
                                        check_number: "",
                                        payee:"",
                                        date_requested: "",
                                        date_of_check: "",
                                        particular: ""
                                      },
                              co_maker_two: online_application.co_maker_last_name,
                              co_maker_one: {
                                value: co_maker.id,
                                label: co_maker.full_name,
                                id: co_maker.id
                              }
                            }


                    }


        config  = { 
                    loan_data: loan_data, 
                    user: current_user, 
                    co_maker_profile_picture: nil, 
                    co_maker_three_profile_picture: nil 
                  }

        data = ::Loans::Save.new(config: config).execute!
        online_application.update!(status: "approved")
        render json: { message: "ok" }
     
      end

      def verify
      
        online_application  = LoanApplication.find(params[:id])
        raise "jef".inspect
      end

      def reject
        online_application  = OnlineApplication.find(params[:id])
        reason              = params[:reason]

        validator = ::OnlineApplications::ValidateReject.new(
                      online_application: online_application,
                      user: current_user,
                      reason: reason
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { full_messages: validator.errors[:full_messages] }, status: 403
        else
          cmd = ::OnlineApplications::Reject.new(
                  online_application: online_application,
                  user: current_user,
                  reason: reason
                )

          cmd.execute!

          render json: { message: "ok" }
        end
      end

      def process_application
        online_application  = OnlineApplication.find(params[:id])
        data_online_application = online_application.data.with_indifferent_access

        validator = ::OnlineApplications::ValidateProcess.new(
                      online_application: online_application,
                      user: current_user
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { errors: validator.errors[:full_messages] }, status: 403
        else
          approve_process = {  type: "process_by",  name: current_user.full_name, date_assign: Date.today  }
          if data_online_application["approve_process"].present?
          
            data_online_application["approve_process"] << approve_process
            online_application.update!(status: "processing", data: data_online_application)
          else
            data_online_application["approve_process"] = []
            data_online_application["approve_process"] << approve_process
            online_application.update!(status: "processing", data: data_online_application)
          end

          ProcessOnlineApplication.perform_later({
            id: online_application.id,
            user_id: current_user.id
          })

          render json: { message: "ok" }
        end
      end
    end
  end
end
