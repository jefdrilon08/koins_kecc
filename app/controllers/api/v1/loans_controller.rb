module Api
  module V1
    class LoansController < ApiController
      before_action :authenticate_user!

      def delay_amort
        amort     = AmortizationScheduleEntry.where(id: params[:id]).first
        user      = current_user
        reason    = params[:reason]
        new_date  = params[:new_date].try(:to_date)

        config  = {
          amort: amort,
          user: user,
          reason: reason,
          new_date: new_date
        }

        errors  = ::Loans::ValidateDelayAmort.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          old_date  = amort.due_date
          loan      = ::Loans::DelayAmort.new(
                        config: config
                      ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} changed amortization #{amort.id} from #{old_date} to #{new_date}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              amortization_schedule_entry_id: amort.id
            }
          )

          render json: { message: "ok" }
        end
      end

      def change_book
        loan  = Loan.where(id: params[:id]).first
        book  = params[:book]

        config  = {
          loan: loan,
          book: book,
          user: current_user
        }

        errors  = ::Loans::ValidateChangeBook.new(
                    config: config
                  ).execute!


        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          old_book  = loan.data.with_indifferent_access[:accounting_entry][:book]
          loan      = ::Loans::ChangeBook.new(
                        config: config
                      ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} changed book from #{old_book} to #{book} for loan #{loan.id}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              loan_id: loan.id
            }
          )

          render json: { message: "ok", id: loan.id }
        end
      end

      def approve
        loan  = Loan.where(id: params[:id]).first

        config  = {
          loan: loan,
          user: current_user
        }

        errors  = ::Loans::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          loan  = ::Loans::Approve.new(
                    config: config
                  ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} approved loan #{loan.id}",
            activity_type: "approval",
            data: {
              user_id: current_user.id,
              loan_id: loan.id
            }
          )

          render json: { message: "ok", id: loan.id }
        end
      end

      def update_date_released
        loan  = Loan.find(params[:id])

        loan.update!(date_released: params[:date_released])

        ActivityLog.create!(
          content: "#{current_user.full_name} updated loan #{loan.id} date_released to #{params[:date_released]}",
          activity_type: "modification",
          data: {
            user_id: current_user.id,
            loan_id: loan.id
          }
        )

        render json: { message: "ok" }
      end

      def update_first_date_of_payment
        loan  = Loan.find(params[:id])

        if params[:first_date_of_payment].blank?
          errors  = {
            messages: [
              { key: "first_date_of_payment", meessage: "First date of payment required" }
            ],
            full_messages: [
              "First date of payment required"
            ]
          }

          render json: errors, status: 400
        else
          loan.update!(first_date_of_payment: params[:first_date_of_payment])

          ::Loans::AmortizeDates.new(
            config: {
              loan: loan
            }
          ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} updated loan #{loan.id} first_date_of_payment to #{params[:first_date_of_payment]}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              loan_id: loan.id
            }
          )

          render json: { message: "ok" }
        end
      end

      def fetch
        member  = Member.where(id: params[:member_id]).first

        if member.blank?
          render json: { message: "member not found" }, status: 400
        else
          loan    = Loan.where(id: params[:id]).first

          config  = {
            member: member,
            loan: loan,
            user: current_user
          }

          loan  = ::Loans::Fetch.new(config: config).execute!

          project_type_categories = ProjectTypeCategory.all.order("name ASC").map{ |c|
                                      {
                                        id: c.id,
                                        name: c.name,
                                        project_types: c.project_types.order("name ASC").map{ |p|
                                          {
                                            id: p.id,
                                            name: p.name
                                          }
                                        }
                                      }
                                    }

          render json: { loan: loan, project_type_categories: project_type_categories }
        end
      end
      
      def delete
        loan    = Loan.where(id: params[:id]).first
        member  = loan.member

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

          render json: { message: "ok", id: member.id }
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

          if loan.first_date_of_payment
            ::Loans::AmortizeDates.new(
              config: {
                loan: loan
              }
            ).execute!
          end

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
