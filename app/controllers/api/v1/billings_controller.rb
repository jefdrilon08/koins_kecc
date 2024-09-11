module Api
  module V1
    class BillingsController < ActionController::Base
      before_action :authenticate_user!

      def fetch
        billing = Billing.find(params[:id])

        render json: billing
      end

      def update_book
        billing = Billing.find(params[:id])
        data    = billing.try(:data).try(:with_indifferent_access)
        book    = params[:book]

        if billing.save?
          data[:accounting_entry][:book]  = book

          billing.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_particular
        billing     = Billing.find(params[:id])
        data        = billing.try(:data).try(:with_indifferent_access)
        particular  = params[:particular]

        if billing.pending? || billing.save?
          data[:accounting_entry][:particular]  = particular

          billing.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_or_number
        billing   = Billing.find(params[:id])
        data      = billing.try(:data).try(:with_indifferent_access)
        or_number = params[:or_number]
        billing[:or_number] = params[:or_number]  
        
        if billing.save?
          data[:or_number]                            = or_number
          data[:accounting_entry][:data][:or_number]  = or_number

          billing.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_ar_number
        billing   = Billing.find(params[:id])
        data      = billing.try(:data).try(:with_indifferent_access)
        ar_number = params[:ar_number]

        if billing.save?
          data[:ar_number]                            = ar_number
          data[:accounting_entry][:data][:ar_number]  = ar_number

          billing.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end
      def update_si_number
        billing   = Billing.find(params[:id])
        data      = billing.try(:data).try(:with_indifferent_access)
        si_number = params[:si_number]
        billing[:si_number] = params[:si_number]
        
        if billing.save?
          data[:si_number]                            = si_number
          data[:accounting_entry][:data][:si_number]  = si_number

          billing.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end
      def toggle_attendance_off
        billing = Billing.find(params[:id])
        data    = billing.data.with_indifferent_access

        data[:records].each_with_index do |o, i|
          data[:records][i][:attendance]  = false
        end

        billing.update!(
          data: data
        )
        
        render json: billing
      end

      def toggle_attendance_on
        billing = Billing.find(params[:id])
        data    = billing.data.with_indifferent_access

        data[:records].each_with_index do |o, i|
          data[:records][i][:attendance]  = true
        end

        billing.update!(
          data: data
        )
        
        render json: billing
      end

      def toggle_attendance
        billing = Billing.find(params[:id])
        data    = billing.data.with_indifferent_access

        data[:records].each_with_index do |o, i|
          if o[:member][:id] == params[:member_id]
            data[:records][i][:attendance]  = !data[:records][i][:attendance]
          end
        end

        billing.update!(
          data: data
        )
        
        render json: billing
      end
      
      def save
        billing = Billing.where(id: params[:id]).first

        config  = {
          billing: billing,
          user: current_user
        }
        errors  = ::Billings::ValidateSave.new(
                    config: config
                  ).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          billing = ::Billings::Save.new(
                    config: config
                  ).execute!
           billing.update!(status: "save")
        end
         
  
          ActivityLog.create!(
            content: "#{current_user.full_name} save billing",
            activity_type: "approval",
            data: {
              user_id: current_user.id,
              billing_id: billing.id
            }
          )

          render json: { message: "ok" }
      end

      def unsave
        billing = Billing.where(id: params[:id]).first

        config  = {
          billing: billing,
          user: current_user
        }

          billing.update!(status: "pending")
  
          ActivityLog.create!(
            content: "#{current_user.full_name} unchecked billing",
            activity_type: "approval",
            data: {
              user_id: current_user.id,
              billing_id: billing.id
            }
          )

          render json: { message: "ok" }
      end

      def check
        billing = Billing.where(id: params[:id]).first

        config  = {
          billing: billing,
          user: current_user
        }

        errors  = ::Billings::ValidateCheck.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          billing = ::Billings::Check.new(
                      config: config
                    ).execute!
          billing.update!(status: "checked")
  
          ActivityLog.create!(
            content: "#{current_user.full_name} checked billing",
            activity_type: "approval",
            data: {
              user_id: current_user.id,
              billing_id: billing.id

            }
          )

          render json: { message: "ok" }
        end
      end

      def uncheck
        billing = Billing.where(id: params[:id]).first
        config  = {
          billing: billing,
          user: current_user
        }
          billing = ::Billings::Uncheck.new(
                      config: config
                    ).execute!
        
          billing.update!(status: "save")
          render json: { message: "ok" }
      end

      def zero_out
        billing = Billing.where(id: params[:id]).first

        config  = {
          billing: billing,
          user: current_user,
          special_report: params[:value_special_report]
        }

        errors  = ::Billings::ValidateZeroOut.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          billing = ::Billings::ZeroOut.new(
                      config: config
                    ).execute!

  
          ActivityLog.create!(
            content: "#{current_user.full_name} zero out billing",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              billing_id: billing.id,
              
                          }
          )

          render json: { message: "ok" }
        end
      end

      def approve
        billing = Billing.where(id: params[:id]).first

        config  = {
          billing: billing,
          user: current_user
        }

        errors  = ::Billings::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          billing.update!(status: "processing")

          ProcessApproveBilling.perform_later({
            id: billing.id,
            user_id: current_user.id
          })

          render json: { message: "ok" }
        end
      end

      def update
        billing_id  = params[:billing_id]
        data        = params[:data]
        changes     = params[:changes]

        billing = Billing.find(billing_id)

        billing.update!(
          status: "processing"
        )

        ProcessBillingUpdate.perform_later({
          id: billing.id,
          user_id: current_user.id,
          data: data,
          changes: changes
        })

        render json: { message: "ok" }
      end

      def modify_member_record
        billing         = Billing.find(params[:id])
        current_member  = params[:current_member]
        member_records  = params[:member_records]
       
        member_record = member_records.values.map do |items| 
          items[:amount]= items[:amount].to_f
          if items[:enabled] == "true"
            items[:enabled] = true
          elsif items[:enabled] == "false"
            items[:enabled] = false
          end
         items
        end


        config = {
          billing: billing,
          current_member: current_member,
          member_records: member_record,
          current_user: current_user
        }

        errors = ::Billings::ValidateModifyMemberRecord.new(config: config).execute!
        
        if errors[:messages].any?
          render json: {errors: errors}, status: 400
        else
          billing = ::Billings::ModifyMemberRecord.new(config: config).execute!
          render json: billing
        end

        
      end

      def modify_transaction_record
        billing             = Billing.find(params[:id])
        current_transaction = params[:current_transaction]
        current_member      = params[:current_member]

        config  = {
          billing: billing,
          current_transaction: current_transaction,
          current_member: current_member,
          user: current_user
        }

        errors  = ::Billings::ValidateModifyTransactionRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: { errors: errors }, status: 400
        else
          billing = ::Billings::ModifyTransactionRecord.new(
                      config: config
                    ).execute!

          render json: billing
        end
      end

      def create
        collection_date = params[:collection_date].try(:to_date)
        branch_id       = params[:branch_id]
        center_id       = params[:center_id]
        billing_type    = params[:billing_type]

        config  = {
          collection_date: collection_date,
          branch_id: branch_id,
          center_id: center_id,
          billing_type: billing_type,
          user: current_user
        }

        errors  = ::Billings::ValidateCreateBilling.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          branch  = ReadOnlyBranch.find(branch_id)
          center  = ReadOnlyCenter.find(center_id)

          billing = Billing.new(
                      collection_date: collection_date,
                      branch: branch,
                      center: center,
                      status: "processing",
                      data: {
                        status: "processing",
                        billing_type: billing_type
                      }
                    )

          billing.save!

        
          
          ProcessCreateBilling.perform_later({
            id: billing.id,
            user_id: current_user.id
          })

#          billing = ::Billings::CreateBilling.new(
#                      config: config
#                    ).execute!
        

          render json: { id: billing.id }
        end
      end
    end
  end
end
