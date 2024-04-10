module Api
  module V1
    class MembersProjectTypesController < ActionController::Base
      before_action :authenticate_user!
      
      def approve
         data_store_id = params[:data_store_id]

         config = {
            data_store_id: data_store_id

         }


         record = ::DataStores::ApproveProjectTypes.new(config: config).execute!

         #DataStore.find(data_store_id).update!(status: "approve").inspect
         
          
         render json: {id: data_store_id}
      end

      def delete
          data_store_id =  params[:data_store_id]
          data_index = params[:data_index].to_i
          
          record = DataStore.find(data_store_id)
          record_data = record.data
          record_data.delete_at(data_index)

          record.update!(data: record_data)
          
          
          render json: { id: data_store_id}

      end
      
      def create
  
          branch_id = params[:branch_id]
          center_id = params[:center_id]  
            


          config = {
            branch: branch_id,
            center: center_id

          }

          
          record = ::DataStores::BuildMemberProjectTypes.new(config: config).execute!
          render json: { id: record.id}
             
      end

      def fetch_project_type_category
        project_type_category = ProjectType.where(project_type_category_id: params[:id], is_active: "true").order("name ASC").map{ |c|
          {
            id: c.id,
            name: c.name
          }
        }
        render json: { project_type_category: project_type_category  }
      end

      def save
          data_store_id =  params[:data_store_id]
          project_category_id = params[:project_category_id]
          project_type_id = params[:project_type_id]
          member_id = params[:member_id]
          latitude_data = params[:latitude_data]
          longtitude_data = params[:longtitude_data]

          config = {
            data_store_id: data_store_id,
            project_category_id: project_category_id,
            project_type_id: project_type_id,
            member_id: member_id,
            latitude_data: latitude_data,
            longtitude_data: longtitude_data

          }


          
          record = ::DataStores::SaveMembersProjectTypes.new(config: config).execute!
          
          

      end

      # for delete


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
          
          
          errors = ::BillingForFullPayments::ValidateWithdrawPayment.new(data_store_id: data_store_id, member_id: member_id, loan_amount: loan_amount).execute!
          if errors[:messages].any? 
            render json: errors, status: 404
          else
            record = ::BillingForFullPayments::UpdateBillingAmount.new(config: config).execute!
          end
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

      def add_particular
        data_store_id   = params[:dataStoreid]
        txt_particular  = params[:txtParticular]

        data_store_details = DataStore.find(data_store_id)
        data_store_details.meta["data"]["particular"] = txt_particular
        data_store_details.save!
      end

      def add_or
        data_store_id   = params[:dataStoreid]
        txt_or  = params[:txtOr]

        data_store_details = DataStore.find(data_store_id)
        data_store_details.meta["data"]["OR"] = txt_or
        data_store_details.save!
      
      end
      
      def add_ar
        data_store_id   = params[:dataStoreid]
        txt_ar  = params[:txtAr]
        
        data_store_details = DataStore.find(data_store_id)
        data_store_details.meta["data"]["AR"] = txt_ar
        data_store_details.save!
        
      end

      def update_book
        data_store_id = params[:dataStoreid]
        selected_book = params[:selectBook]
        
        data_store_details = DataStore.find(data_store_id)
        data_store_details.meta["data"]["book"] = selected_book
        data_store_details.save!

      
      end



      def approved
        data_store_id   = params[:dataStoreid]
        @billing_data_store = DataStore.find(data_store_id)
        config = {
            data_store_id: data_store_id

        }
        errors = ::BillingForFullPayments::ValidateApprovedBilling.new(config: config).execute!
                
        if errors[:messages].any? 
          render json: errors, status: 404
        else
          @billing_data_store.update(status: "processing")
        

          ProcessApproveBillingForFullPayment.perform_later({
              data_store_id: data_store_id,
              full_payment_billing: @billing_data_store,
              user_id: current_user.id
          })

        
          
          render json: { message: "ok" }
        end 
      end
      def checked
        data_store_id = params[:dataStoreid]
        data_store_details = DataStore.find(data_store_id)
        data_store_details.meta["is_checked"] = true
        data_store_details.save!

      end
    end
  end
end
