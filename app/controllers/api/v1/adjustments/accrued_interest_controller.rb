module Api
  module V1
    class AccruedInterestController < ApplicationController
      def create
          branch  = Branch.where(id: params[:branch_id]).first
          center  = Center.where(id: params[:center_id]).first
          member  = Member.where(id: params[:member_id]).first
          loans   = Loan.where(id: params[:loan_ids])
          
          cut_off_date  = params[:cut_off_date]
          start_date  = params[:start_date]
          end_date  = params[:end_date]
          number_of_days    = params[:number_of_days]
          number_of_moratorium    = params[:number_of_moratorium]
      end
    end
  end
end
