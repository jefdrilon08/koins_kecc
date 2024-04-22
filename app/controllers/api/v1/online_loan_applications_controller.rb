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
      
      def change_amount
      
        online_application  = LoanApplication.find(params[:id])
        online_application.update!(amount: params[:amount].to_f)
        render json: { message: "ok" }
     
      end
      
      def reject
       
        online_application  = LoanApplication.find(params[:id])
        online_application.update!(status: "reject")
        render json: { message: "ok" }
     
      end
      
      def reject_approve
        online_application  = LoanApplication.find(params[:id])
        
        online_application_data = online_application.data
        online_application_data[:reason_approve_reject] = params[:reason_reject]
        online_application_data[:date_approve_reject] = Date.today
        online_application.update!(status: "for_review", data: online_application_data)
        render json: { id: params[:id] }
      end

      def decline
        online_application  = LoanApplication.find(params[:id])
        
        online_application_data = online_application.data
        online_application_data[:reason_approve_reject] = params[:reason_reject]
        online_application_data[:date_approve_reject] = Date.today
        online_application.update!(status: "reject", data: online_application_data)
        render json: { id: params[:id] }
      end

      def check
        online_application  = LoanApplication.find(params[:id])
        online_application_data = online_application.data


        online_application_data['check_cash_flow'] = {}
        online_application_data['check_cash_flow']['check_verify'] = true
        online_application_data['check_cash_flow']['user'] = current_user.id
        online_application_data['check_cash_flow']['first_name'] = current_user["first_name"]
        online_application_data['check_cash_flow']['last_name'] = current_user["last_name"]
        online_application_data['check_cash_flow']['date_check'] = Date.today

        online_application.update(data:online_application_data)
        render json: {message: "ok"}

      end

      def reject_checking
        online_application  = LoanApplication.find(params[:id])
        online_application_data = online_application.data
        online_application_data[:reason_of_reject] = params[:reason_reject]
        online_application_data[:date_reject] = Date.today
        online_application.update!(status: "reject", data: online_application_data)
        render json: { id: params[:id] }
      end
      
      def for_review
      
        online_application  = LoanApplication.find(params[:id])
        online_application_data = online_application.data

        online_application.update!(status: "for_review", data: online_application_data)
        render json: { message: "ok" }

         
      end

      def for_approve     
        online_application  = LoanApplication.find(params[:id])
        online_application_data = online_application.data

        online_application_data['so_recommendation'] = {}
        online_application_data['so_recommendation']['check_verify'] = true
        online_application_data['so_recommendation']['user'] = current_user.id
        online_application_data['so_recommendation']['first_name'] = current_user["first_name"]
        online_application_data['so_recommendation']['last_name'] = current_user["last_name"]
        online_application_data['so_recommendation']['date_check'] = Date.today
        online_application_data['so_recommendation']['time_check'] = Time.now.strftime("%I:%M:%S %p")

        
        online_application.update!(status: "for_approve")
        
        render json: { message: "ok" }
     
      end
      
      def update_details
        online_loan_application  = LoanApplication.find(params[:id])
        online_loan_application_data  = online_loan_application.data
        online_loan_application_data['so_file']['palya_sa_pagiimpok'] =  params[:palya_sa_pagiimpok]
        online_loan_application_data['so_file']['bilang_ng_absent'] =  params[:bilang_ng_absent]
        online_loan_application_data['so_file']['sit_down'] =  params[:sit_down]
        online_loan_application_data['so_file']['kasalukuyang_insurance'] =  params[:kasalukuyang_insurance]
        online_loan_application_data['so_file']['tungkulin_bilang_co_maker'] =  params[:tungkulin_bilang_co_maker]
        
        online_loan_application_data['cash_flow']['kita_sa_negosyo'] =  params[:kita_sa_negosyo]
        online_loan_application_data['cash_flow']['kita_mula_sa_asawa'] =  params[:kita_mula_sa_asawa]
        online_loan_application_data['cash_flow']['kita_mula_sa_kasama'] =  params[:kita_mula_sa_kasama]
        
        online_loan_application_data['cash_flow']['iba_pang_pinagkakakitaan'] =  params[:iba_pang_pinagkakakitaan]

        online_loan_application_data['cash_flow']['gastos_sa_pagkain'] =  params[:gastos_sa_pagkain]
        online_loan_application_data['cash_flow']['gastos_sa_baon'] =  params[:gastos_sa_baon]
        online_loan_application_data['cash_flow']['gastos_sa_gamot'] =  params[:gastos_sa_gamot]
        online_loan_application_data['cash_flow']['bayarin_sa_tubig'] =  params[:bayarin_sa_tubig]
        online_loan_application_data['cash_flow']['iba_pa'] =  params[:iba_pa]
        
        online_loan_application_data['cash_flow']['hulugan_sa_coop'] =  params[:hulugan_sa_coop]
        online_loan_application_data['cash_flow']['hulugan_bukod_sa_coop'] =  params[:hulugan_bukod_sa_coop]

        online_loan_application.update!(data: online_loan_application_data)
        
        render json: { id: params[:id] }

      
      end
      
      def approve_loan
    
        online_application  = LoanApplication.find(params[:id])
        online_application_data = Member.find(online_application.member_id)

        member = Member.find(online_application.member_id)
        member = Member.find(online_application.member_id)
        co_maker = Member.find(online_application.co_maker_member_id) 
        loan_data = {
                      id: nil,
                      branch_id: member.branch_id,
                      center_id: member.center_id,
                      date_prepared: Date.today,
                      member_id: member.id,
                      principal: online_application.amount,
                      loan_product_id: online_application.loan_product_id,
                      term: online_application.term,
                      pn_number: online_application.reference_number,
                      num_installments: online_application.num_installments,
                      project_type_id: online_application.data['project_type_id'],
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
                                id: co_maker.id,
                                first_name: co_maker.first_name , 
                                middle_name: co_maker.middle_name,
                                last_name: co_maker.last_name
                              },
                              clip_beneficiary: {
                                first_name: online_application.data['clip_beneficiary']['first_name'],
                                middle_name: online_application.data['clip_beneficiary']['middle_name'],
                                last_name: online_application.data['clip_beneficiary']['last_name'],
                                date_of_birth: online_application.data['clip_beneficiary']['date_of_birth'],
                                relationship: online_application.data['clip_beneficiary']['relationship']

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

      
        content = "Hi #{online_application_data[:first_name]}! Ang Iyong Loan na P#{online_application.amount} sa KCOOP ay naaprubahan na. Loan Reference # #{online_application.reference_number} Maghintay ng abiso ng SO kung kailan ang Loan Release."
        sms = {
          mobile_number: online_application.data["mobile_number"],
          content: content
        }
        ::SmsBlast::Send.new(config: sms).execute!
        #puts "jaysoooooooooooooooooooon" + sms.inspect
      
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
