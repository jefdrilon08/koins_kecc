module Api
  module V1
    class BillingForFullPaymentsController < ApplicationController
      
      def create
  
          branch_id = params[:branch_id]
          center_id = params[:center_id]  
          collection_date = params[:collection_date]
            


          config = {
            branch: branch_id,
            center: center_id,
            collection_date: collection_date

          }

          



          record = ::BillingForFullPayments::SaveBillingForFullPayments.new(
                                                                                config: config
                                                                              ).execute!
             
      end

      def update_amount
            member_id =          params[:member_id]
            member_account_id =  params[:member_account_id]
            data_store_id =      params[:data_store_id]
            record_type =        params[:record_type]
            loan_amount =        params[:loan_amount]
          config = {
            member_id:          member_id,
            member_account_id:  member_account_id,
            data_store_id:      data_store_id,
            record_type:       record_type,
            loan_amount:        loan_amount
           }
          
          
          #errors = ::BillingForFullPayments::ValidatePayment.new(config: config).execute!
          
          record = ::BillingForFullPayments::UpdateBillingAmount.new(config: config).execute!
           
      end

      def add_member
        data_store_id   = params[:data_store_id]
        member_id       = params[:member_id]
        member_loan_id  = params[:member_loan_id]
        config = {
        data_store_id:  data_store_id,
        member_id:      member_id,
        member_loan_id: member_loan_id

        } 
        
        errors = ::BillingForFullPayments::ValidateAddMember.new(config: config).execute!
      
        if errors[:messages].any?
          
          render json: errors, status: 400
        else

        add_record = ::BillingForFullPayments::AddMember.new(config: config).execute!
        end


      end

      def remove_payment_member
        config = {
          loanProductId: params[:loanProductId],
          memberId: params[:memberId],
          dataStoreId: params[:dataStoreId],
          loanId: params[:loanId]
        }

        remove_record = ::BillingForFullPayments::RemoveMemberPayment.new(config: config).execute!
      end



    end
  end
end
