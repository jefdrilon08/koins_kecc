module Api
  module V1
    class AccruedPaymentCollectionsController < ActionController::Base
      before_action :authenticate_user!
    	def create
    		collection_date = params[:collection_date].try(:to_date)
        	branch_id       = params[:branch_id]
                branch          = Branch.find(branch_id)
        	center_id       = params[:center_id]
                member_id       = params[:member_id]


        	config  = {
          		collection_date: collection_date,
                        branch:    branch,
          		branch_id: branch_id,
          		center_id: center_id,
                        member_id: member_id,
          		user: current_user
        	}
               errors = :: AccruedPaymentCollections::ValidateCreateAccruedPaymentCollection.new(config: config).execute!
               if errors[:messages].any?
                render json: errors, status: 400
              else
                accrued_payment_collection = ::AccruedPaymentCollections::CreateAccruedPaymentCollection.new(config: config).execute!
                render json: { message: "Done" }
              end

          #render json: { message: "ok", id: accrued_payment_collection.id }
    	end

        def update_transaction
          data_store_id       = params[:data_store_id]
          member_id           = params[:member_id].to_i
          member_account_id   = params[:member_account_id].to_i
          loan_amount         = params[:loan_amount].to_f
          config              = {
                                data_store_id: data_store_id,
                                member_id: member_id,
                                member_account_id: member_account_id,
                                loan_amount: loan_amount                     
                                }
          errors = ::AccruedPaymentCollections::ValidateWithdrawPayment.new(data_store_id: data_store_id, member_id: member_id, loan_amount: loan_amount, member_account_id: member_account_id).execute!
          if errors[:messages].any? 
            render json: errors, status: 404
          else
            update_transaction = ::AccruedPaymentCollections::UpdateTransaction.new(
                                            config: config
                                          ).execute!
          end
  
        end
        
        def approve_transaction
          data_store_id = params[:id]
          config        = {data_store_id: data_store_id,
                          user: current_user}
          approve_transaction = ::AccruedPaymentCollections::ApproveTransaction.new(
                                            config: config
                                          ).execute!

        end

        def process_zero
          data_store_id = params[:id]
          config        = {data_store_id: data_store_id}

          approve_transaction = ::AccruedPaymentCollections::ProcessZero.new(
                                            config: config
                                          ).execute!

        end

        def delete
          data_store_id = params[:id]
          config        = {data_store_id: data_store_id}

          delete_transaction = ::AccruedPaymentCollections::Delete.new(
                                            config: config
                                          ).execute!
        end

        def add_particular
          data_store_id     = params[:id]
          txtParticular    =  params[:txtParticular]

          ab = AccruedBilling.find(data_store_id)
          ab.data['accounting_entry']['particular'] = txtParticular
          ab.save!
        end

        def add_or
          data_store_id     = params[:id]
          txtOr    =  params[:txtOr]

          ab = AccruedBilling.find(data_store_id)
          ab.data['accounting_entry']['data']['or_number'] = txtOr
          ab.save!
 
        end

        def add_ar
          data_store_id = params[:id]
          txtAr    =  params[:txtAr]

          ab = AccruedBilling.find(data_store_id)
          ab.data['accounting_entry']['data']['ar_number'] = txtAr
          ab.save!
 
        end
 
        def add_book_type
          data_store_id = params[:id]
          txtBt    =  params[:txtBookType]
          ab = AccruedBilling.find(data_store_id)
          if txtBt == ""
          else
            ab.data['accounting_entry']['book'] = txtBt
            ab.save!
          end
        end
 
    end
  end
end
