module Api
  module V1
    module Adjustments
      class AccruedInterestsController < ApplicationController
        before_action :authenticate_user!
        def create
          branch = Branch.where(id: params[:branch_id]).first
          center = Center.where(id: params[:center_id]).first
          cut_off_date      = params[:date_initialized]
          start_date        = params[:start_date]
          end_date          = params[:end_date]
          #number_of_days    = params[:number_of_days]
          accrued_type      = params[:select_accrued_type]
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
          user = current_user
          
          config = {
                      accrued_interest: accrued_interest,
                      user: user
                    }


          approved_accrued_interest = ::Adjustments::AccruedInterests::ApprovedAccruedInterests.new(config: config).execute!

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




      end
    end
  end
end
