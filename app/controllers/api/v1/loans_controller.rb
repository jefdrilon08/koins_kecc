module Api
  module V1
    class LoansController < ApiController
      before_action :authenticate_user!

      def fetch
        member  = Member.where(id: params[:member_id]).first

        if member.blank?
          render json: { message: "member not found" }, status: 402
        else
          loan    = Loan.where(id: params[:id]).first

          config  = {
            member: member,
            loan: loan,
            user: current_user
          }

          loan  = ::Loans::Fetch.new(config: config).execute!

          render json: loan
        end
      end
      
      def delete
        loan  = Loan.where(id: params[:id]).first

        config  = {
          loan: loan,
          user: current_user
        }

        errors  = ::Loans::ValidateDelete.new( 
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          loan_data = JSON.parse(loan.to_json).with_indifferent_access

          loan  = ::Loans::Delete.new(
                    config: config
                  ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} deleted loan #{loan_data[:id]}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              loan_id: loan_data[:id],
              loan_data: loan_data
            }
          )

          render json: { message: "ok" }
        end
      end

      def save
        loan_data = JSON.parse(params[:data]).to_h.with_indifferent_access
        
        config  = {
          loan_data: loan_data,
          user: current_user
        }

        errors  = ::Loans::ValidateSave.new(
                    config: config
                  ).execute!

        if errors[:full_messages].size > 0
          render json: errors, status: 400
        else
          loan  = ::Loans::Save.new(
                    config: config
                  ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} modified loan #{loan.id}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              loan_id: loan.id,
              loan_data: loan_data
            }
          )

          render json: { id: loan.id }
        end
      end

      def apply
        loan_product  = LoanProduct.where(id: params[:loan_product_id]).first
        member        = Member.where(id: params[:member_id]).first

        config  = {
          loan_product: loan_product,
          member: member,
          user: current_user
        }

        errors  = ::Loans::ValidateApply.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          loan  = ::Loans::Apply.new(
                    config: config
                  ).execute!

          render json: { id: loan.id }
        end
      end

      def reage
        loan        = Loan.where(id: params[:id]).first
        approved_by = current_user.full_name

        errors  = ::Loans::ValidateReage.new( 
                    loan: loan,
                    approved_by: approved_by
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          loan  = ::Loans::Reage.new(
                    loan: loan,
                    approved_by: approved_by
                  ).execute!

          render json: { message: "ok", id: loan.id }
        end
      end
    end
  end
end
