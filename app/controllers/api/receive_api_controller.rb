module Api
  class ReceiveApiController < ActionController::API
    # API FOR MEMBERS
    def save_members_api
      @members = []
      config = {}

      # raise params[:_json].inspect      
      members = params[:_json]
      # puts "Number of Members to be Upload #{members.count}"
      # raise member_data.inspect
        
      members.each do |m|
        @member_data  = {}
        @member_data[:center_id]                    = m["center_id"]
        @member_data[:branch_id]                    = m["branch_id"]
        @member_data[:first_name]                   = m["first_name"]
        @member_data[:middle_name]                  = m["middle_name"]
        @member_data[:last_name]                    = m["last_name"]
        @member_data[:gender]                       = m["gender"]
        @member_data[:date_of_birth]                = m["date_of_birth"]
        @member_data[:civil_status]                 = m["civil_status"]
        @member_data[:home_number]                  = m["home_number"]
        @member_data[:mobile_number]                = m["mobile_number"]
        @member_data[:processed_by]                 = m["processed_by"]
        @member_data[:approved_by]                  = m["approved_by"]
        @member_data[:identification_number]        = m["identification_number"]
        @member_data[:place_of_birth]               = m["place_of_birth"]     
        @member_data[:status]                       = m["status"]
        @member_data[:member_type]                  = m["member_type"]
        @member_data[:religion]                     = m["religion"]
        @member_data[:insurance_status]             = m["insurance_status"]
        @member_data[:data]                         = m["data"]
        @member_data[:date_resigned]                = m["date_resigned"]
        @member_data[:meta]                         = m["meta"]
        @member_data[:created_at]                   = m["created_at"]
        @member_data[:updated_at]                   = m["updated_at"]
        @member_data[:access_token]                 = m["access_token"]
        @member_data[:signature_data]               = m["signature_data"]
        @member_data[:modifiable]                   = m["modifiable"]
        @member_data[:previous_date_resigned]       = m["previous_date_resigned"]
        @member_data[:insurance_date_resigned]      = m["insurance_date_resigned"]
        @member_data[:member_id]                    = m["member_id"]
        @member_data[:encrypted_password]           = m["encrypted_password"]
        @member_data[:username]                     = m["username"]
        @member_data[:online_application_id]        = m["online_application_id"]
        @member_data[:membership_arrangement_id]    = m["membership_arrangement_id"]
        @member_data[:membership_type_id]           = m["membership_type_id"]
        @member_data[:referrer_id]                  = m["referrer_id"]
        @member_data[:coordinator_id]               = m["coordinator_id"]
        @member_data[:email]                        = m["email"]
        @member_data[:external_ref]                 = m["external_ref"]

        # raise @member_data.inspect
        @members << @member_data 

        # raise @member_data.inspect 
        config = @members.map{ |o|
          {
            center_id: o[:center_id],
            branch_id: o[:branch_id],
            first_name: o[:first_name],
            middle_name: o[:middle_name],
            last_name: o[:last_name],
            gender: o[:gender],
            date_of_birth: o[:date_of_birth],
            civil_status: o[:civil_status],
            home_number: o[:home_number],
            mobile_number: o[:mobile_number],
            processed_by: o[:processed_by],
            approved_by: o[:approved_by],
            identification_number: o[:identification_number],
            place_of_birth: o[:place_of_birth],
            status: o[:status],
            member_type: o[:member_type],
            religion: o[:religion],
            insurance_status: o[:insurance_status],
            data: o[:data],
            date_resigned: o[:date_resigned],
            meta: o[:meta],
            created_at: o[:created_at],
            updated_at: o[:update_at],
            access_token: o[:access_token],
            signature_data: o[:signature_data],
            modifiable: o[:modifiable],
            previous_date_resigned: o[:previous_date_resigned],
            insurance_date_resigned: o[:insurance_date_resigned],
            member_id: o[:member_id],
            encrypted_password: o[:encrypted_password],
            username: o[:username],
            online_application_id: o[:online_application_id],
            membership_arrangement_id: o[:membership_arrangement_id],
            membership_type_id: o[:membership_type_id],
            referrer_id: o[:referrer_id],
            coordinator_id: o[:coordinator_id],
            email: o[:email],
            external_ref: o[:external_ref]
          }
        }
      end

      errors = ::Kmba::ValidateSaveMembers.new(
        config: config
      ).execute!

      if errors[:full_messages].any?
      render json: errors, status: 400
      else
        config.each do |a|
        @member = Member.where(identification_number: a[:identification_number])
          # raise @member.inspect
          member_data = {
            center_id: a[:center_id],
            branch_id: a[:branch_id],
            first_name: a[:first_name],
            middle_name: a[:middle_name],
            last_name: a[:last_name],
            gender: a[:gender],
            date_of_birth: a[:date_of_birth],
            civil_status: a[:civil_status],
            home_number: a[:home_number],
            mobile_number: a[:mobile_number],
            processed_by: a[:processed_by],
            approved_by: a[:approved_by],
            identification_number: a[:identification_number],
            place_of_birth: a[:place_of_birth],
            status: a[:status],
            member_type: a[:member_type],
            religion: a[:religion],
            insurance_status: a[:insurance_status],
            data: a[:data],
            date_resigned: a[:date_resigned],
            meta: a[:meta],
            created_at: a[:created_at],
            updated_at: a[:update_at],
            access_token: a[:access_token],
            signature_data: a[:signature_data],
            modifiable: a[:modifiable],
            previous_date_resigned: a[:previous_date_resigned],
            insurance_date_resigned: a[:insurance_date_resigned],
            member_id: a[:member_id],
            encrypted_password: a[:encrypted_password],
            username: a[:username],
            online_application_id: a[:online_application_id],
            membership_arrangement_id: a[:membership_arrangement_id],
            membership_type_id: a[:membership_type_id],
            referrer_id: a[:referrer_id],
            coordinator_id: a[:coordinator_id],
            email: a[:email],
            external_ref: a[:external_ref]
          }
          
          if @member.count > 1
            Rails.logger.info(puts("#{a[:identification_number]} Duplicate"))
          elsif @member.count == 1 
            cmd = ::Kmba::UpdateMembers.new(
              member_data: member_data
            ).execute!
          else
            cmd = ::Kmba::SaveMembers.new(
              member_data: member_data
            ).execute!   
          end

          # count member save and update
          # if @member.present?
          #   Rails.logger.info(puts("#{@member.count}"))
          # end
        end 
      end    
    end

    # API FOR PAYMENTS
    def save_payments_api
      @payments = []
      @transaction = []
      config = {}

      # raise params[:_json].inspect
      payments = params[:_json]

      payments.each do |m|

        @payment_data = {}

        @payment_data[:member_id]                 =m["member_id"]
        @payment_data[:account_subtype]           =m["account_subtype"]
        @payment_data[:subsidiary_id]             =m["subsidiary_id"]
        @payment_data[:subsidiary_type]           =m["subsidiary_type"]
        @payment_data[:amount]                    =m["amount"]
        @payment_data[:transaction_type]          =m["transaction_type"]
        @payment_data[:transacted_at]             =m["transacted_at"]
        @payment_data[:status]                    =m["status"]
        @payment_data[:data]                      =m["data"]
        @payment_data[:created_at]                =m["created_at"]
        @payment_data[:updated_at]                =m["updated_at"]

        # raise @payment_data.inspect
        @payments << @payment_data 
        # raise @payments.inspect

        @member_id = MemberAccount.where(member_id: m[:member_id])
        @member_id.each do |o|
          @account_transaction = {}
          @account_transaction[:id]                     =o[:id]
          @account_transaction[:member_id]              =o[:member_id]
          @account_transaction[:account_type]           =o[:account_type]
          @account_transaction[:account_subtype]        =o[:account_subtype]
          @account_transaction[:balance]                =o[:balance]
          @account_transaction[:center_id]              =o[:center_id]  
          @account_transaction[:branch_id]              =o[:branch_id]
          @account_transaction[:status]                 =o[:status]
          @account_transaction[:maintaining_balance]    =o[:maintaining_balance]
          @account_transaction[:created_at]             =o[:created_at]
          @account_transaction[:data]                   =o[:data]

          @transaction << @account_transaction
        end

        raise @transaction.inspect

        
        
        config = @payments.map{ |o|
          {
            subsidiary_id: @subsidiary_id,
            subsidiary_type: o[:subsidiary_type],
            amount: o[:amount],
            transaction_type: o[:transaction_type],
            transacted_at: o[:transacted_at],
            status: o[:status],
            data: o[:data],
            created_at: o[:created_at],
            updated_at: o[:updated_at]  
          }
        }
        # raise config.inspect
      end

      errors = ::Kmba::ValidateSavePayment.new(
        config: config
      ).execute!


      if errors[:full_messages].any?
        render json: errors, status: 400
      else
        config.each do |a|
          @payment = AccountTransaction.where(subsidiary_id: a[:subsidiary_id])
          # raise @payment.inspect
          payment_data = {
            subsidiary_id: a[:subsidiary_id],
            subsidiary_type: a[:subsidiary_type],
            amount: a[:amount],
            transaction_type: a[:transaction_type],
            transacted_at: a[:transacted_at],
            status: a[:status],
            data: a[:data],
            created_at: a[:created_at],
            updated_at: a[:updated_at]  
          }

          #can payment have to update? or only save? 
          if @payment.count > 0
            cmd = Kmba::SavePayment.new(
              payment_data: payment_data
            ).execute!
          # else
          #   cmd = Kmba::UpdatePayments.new(
          #     payment_data: payment_data
          #   ).execute!
          end
        end
      end  
    end

    # API FOR CLAIMS
    def save_claims_api
      @claims = []
      config = {}

      claims = params[:_json]

      # raise claims.inspect
      claims.each do |c|
        @claims_data = {}
        @claims_data[:date_prepared]                      = c[:date_prepared]
        @claims_data[:prepared_by]                        = c[:prepared_by]
        @claims_data[:created_at]                         = c[:created_at]
        @claims_data[:updated_at]                         = c[:updated_at]
        @claims_data[:member_id]                          = c[:member_id]
        @claims_data[:center_id]                          = c[:center_id]
        @claims_data[:branch_id]                          = c[:branch_id]
        @claims_data[:claim_type]                         = c[:claim_type]
        @claims_data[:data]                               = c[:data]
        @claims_data[:status]                             = c[:status]
        @claims_data[:approved_by]                        = c[:approved_by]
        @claims_data[:checked_by]                         = c[:checked_by]
        @claims_data[:date_checked]                       = c[:date_checked]
        @claims_data[:date_approved]                      = c[:date_approved]
        @claims_data[:posted_by]                          = c[:posted_by]
        @claims_data[:date_posted]                        = c[:date_posted]
      end

      # raise @claims_data.inspect
      @claims << @claims_data
      # raise @claims.inspect

      config  = @claims.map { |o|
        {
          date_prepared: o[:date_prepared],
          prepared_by: o[:prepared_by],
          created_at: o[:created_at],
          updated_at: o[:updated_at],
          member_id: o[:member_id],
          center_id: o[:center_id],
          branch_id: o[:branch_id],
          claim_type: o[:claim_type],
          data: o[:data],
          status: o[:status],
          approved_by: o[:approved_by],
          checked_by: o[:checked_by],
          date_checked: o[:date_checked],
          date_approved: o[:date_approved],
          posted_by: o[:posted_by],
          date_posted: o[:date_posted]
        }
      }

      # raise config.inspect
      errors = ::Kmba::ValidateSaveClaims.new(
        config: config
      ).execute!

      if errors[:full_messages].any?
      render json: errors, status: 400
      else
        config.each do |a|  
          @claims = Claim.where(member_id: a[:member_id])

          claims_data = {
            date_prepared: a[:date_prepared],
            prepared_by: a[:prepared_by],
            created_at: a[:created_at],
            updated_at: a[:updated_at],
            member_id: a[:member_id],
            center_id: a[:center_id],
            branch_id: a[:branch_id],
            claim_type: a[:claim_type],
            data: a[:data],
            status: a[:status],
            approved_by: a[:approved_by],
            checked_by: a[:checked_by],
            date_checked: a[:date_checked],
            date_approved: a[:date_approved],
            posted_by: a[:posted_by],
            date_posted: a[:date_posted]
          }

          if @claims.count == 1
            if a[:status] == 'approved'
              # cmd = ::Kmba::UpdateClaims.new(
              #   claims_data: claims_data
              # ).execute!
            end
          # else
          #   cmd = ::Kmba::SaveClaims.new(
          #     claims_data: claims_data
          #   ).execute!
          end
        end
      end
    end
  end
end
