module Api
  module V1
    module Adjustments
      class AccruedInterestsController < ApplicationController
        before_action :authenticate_user!
        def create
          branch_id = params[:branch_id]
          branch = Branch.where(id: params[:branch_id]).first
          center = Center.where(id: params[:center_id]).first
          cut_off_date      = params[:date_initialized]
          start_date        = params[:start_date]
          end_date          = params[:end_date]
          #number_of_days    = params[:number_of_days]
          #accrued_type      = params[:select_accrued_type]
          accrued_type      = "INDIVIDUAL"
          number_of_moratorium_days = params[:input_number_of_moratorium_days]
          member            = Member.where(id: params[:member_id]).first
          loans             = Loan.where(id: params[:loan_ids])
          

      

              

        
          config = {
            branch: branch,
            center: center, 
            cut_off_date: cut_off_date,
            start_date: start_date,
            end_date:end_date,
            accrued_type: accrued_type,
            member: member,
            loans: loans,
            number_of_moratorium_days:  number_of_moratorium_days
          
          }
          

          record = ::Adjustments::AccruedInterests::Create.new(
                                                                config: config
                                                               ).execute!
          



        end
        def process_accrued
          accrued_interest_id = params[:id]
          accrued_interest = AccruedInterest.where(id: params[:id]).first
          #user = current_user
          

          
          #config = {
          #            accrued_interest: accrued_interest,
          #            user: user
          #          }
        
          args = {
                    id: accrued_interest_id,
                    user_id: current_user.id
          }
          
          accrued_interest.update!(status: "processing")
          
          ProcessApprovedAccruedInterests.perform_later(args)


          render json: { message: "ok" }
        end
        def delete
        
          accrued_interest = AccruedInterest.find(params[:id])
          if !accrued_interest.status == "pending"
            raise "Invalid record #{accrued_interest.id}"
          else
            accrued_interest.destroy!
          end
          render json: { message: "ok" }
        end

        def batch_process    
          branch_id = params[:branch_id]
          branch = Branch.where(id: params[:branch_id]).first
          #batchnumberOfDays = params[:batchnumberOfDays]
          batchnumberOfDays = 0
          batchStartDate = params[:batchStartDate]
          batchEndDate = params[:batchEndDate]  
          #batchAccruedType = params[:batchAccruedType]
          batchAccruedType = "BLANKET"
          inputDateInitializedCutOff = params[:inputDateInitializedCutOff]
          #inputDateInitializedCutOff = 0
          config = {
            branch: branch,
            cut_off_date: inputDateInitializedCutOff,
            start_date: batchStartDate,
            end_date:  batchEndDate,
            number_of_moratorium_days:  batchnumberOfDays,
            accrued_type: batchAccruedType
          
          }
        
          record = ::Adjustments::AccruedInterests::CreateBatch.new(
                                                                config: config
                                                               ).execute!
          
        end

        def remove
          data_loan_id =  params[:id]
          accrued_id = params[:accrued_id]
          accrued_interest = AccruedInterest.find(params[:accrued_id])
          accrued_interest_data = accrued_interest.data.with_indifferent_access
          
          accrued_interest_data[:active_loans].select{ |o| o[:id] == data_loan_id  }.last[:cut_off_status] = "invalid"
          
          
          accrued_interest.update(data: accrued_interest_data)
          render json: { message: "ok" }
          
        end

        def erase_record
          data_loan_id = params[:id]
          #accrued_id = params[:accrued_id]
         

          loan = Loan.find(data_loan_id)
          loan_data = loan.data.with_indifferent_access
          loan_data[:accrued_interest][:status] = "remove"
          loan.update(data: loan_data)
          render json: { message: "ok" }
        
        end


      end
    end
  end
end
