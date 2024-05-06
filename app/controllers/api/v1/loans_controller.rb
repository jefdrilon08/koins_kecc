module Api
  module V1
    class LoansController < ApiController
      before_action :authenticate_user!
      

      def reverse_approve_loan_reason
        loan = Loan.find( params[:id])

        loan_details =  ::Loans::ApproveLoanReverse.new(
            user: current_user,
            loan: loan
          ).execute!

        
          ActivityLog.create!(
            content: "#{current_user.full_name} approved reverse loan with JVB refference number #{loan.data.with_indifferent_access[:reverse_loan_details].last[:refference_number]} ",
            activity_type: "approval",
            data: {
              user_id: current_user.id,
              loan_id: loan.id
            }
          )

        render json: { message: "ok", id: loan.id }
      end


      def reverse_loan
             
        loan = Loan.find( params[:id])

        loan_details =  ::Loans::ReverseLoan.new(
            user: current_user,
            loan: loan
          ).execute!
          
          ActivityLog.create!(
            content: "#{current_user.full_name}  reverse loan  ",
            activity_type: "reverse",
            data: {
              user_id: current_user.id,
              loan_id: loan.id
            }
          )

        

        render json: { message: "ok", id: loan.id }
      end
      
      def reverse_loan_reason
        loan = Loan.find(params[:id])

        reason_details =  params[:reason_details].inspect
        config = {
          loan: loan,
          reason_details: reason_details
        }        
      
        result = ::Loans::AddReverseReason.new(config: config).execute!

      end
      
      def fetch_by_member
        active_loans  = Loan.active.includes(:loan_product).where(member_id: params[:member_id])

        result  = active_loans.map{ |o|
                    {
                      id: o.id,
                      loan_product: {
                        id: o.loan_product.id,
                        name: o.loan_product.name
                      }
                    }
                  }

        render json: { loans: result }
      end

      def fetch_by_member_for_recompute
        active_loans  = Loan.active.includes(:loan_product).where(member_id: params[:member_id])

        result  = active_loans.map{ |o|
                    {
                      id: o.id,
                      loan_product: {
                        id: o.loan_product.id,
                        name: o.loan_product.name
                      }
                    }
                  }

        render json: { loans: result }
      end

      def upload_application_form
        loan  = Loan.find_by_id(params[:id])
        files = params[:files]

        config = {
          user: current_user,
          files: files,
          loan: loan
        }

        errors  = ::Loans::ValidateUploadApplicationForm.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: { errors: errors }, status: 400
        else
          loan.update!(application_form: config[:files][0])

          render json: { message: "ok" }
        end
      end

      def reject
        loan    = Loan.find_by_id(params[:id])
        reason  = params[:reason]

        validator = ::Loans::ValidateReject.new(
                      user: current_user,
                      loan: loan,
                      reason: reason
                    )

        validator.execute!

        if validator.errors[:full_messages].any?
          render json: { errors: validator.errors }, status: 400
        else
          ::Loans::Reject.new(
            user: current_user,
            loan: loan,
            reason: reason
          ).execute!

          render json: { message: "ok" }
        end
      end

      def for_release
        loan  = Loan.find_by_id(params[:id])

        validator = ::Loans::ValidateForRelease.new(
                      user: current_user,
                      loan: loan
                    )

        validator.execute!

        if validator.errors[:full_messages].any?
          render json: { errors: validator.errors }, status: 400
        else
          ::Loans::ForRelease.new(
            user: current_user,
            loan: loan
          ).execute!

          render json: { message: "ok" }
        end
      end

      def process_loan
        loan  = Loan.find_by_id(params[:id])

        validator = ::Loans::ValidateProcess.new(
                      user: current_user,
                      loan: loan
                    )

        validator.execute!

        if validator.errors[:full_messages].any?
          render json: { errors: validator.errors }, status: 400
        else
          ::Loans::Process.new(
            user: current_user,
            loan: loan
          ).execute!

          render json: { message: "ok" }
        end
      end

      def verify
        loan  = Loan.find_by_id(params[:id])

        validator = ::Loans::ValidateVerify.new(
                      user: current_user,
                      loan: loan
                    )

        validator.execute!

        if validator.errors[:full_messages].any?
          render json: { errors: validator.errors }, status: 400
        else
          ::Loans::Verify.new(
            user: current_user,
            loan: loan
          ).execute!

          render json: { message: "ok" }
        end
      end

      def restructure
        loan_product      = LoanProduct.where(id: params[:loan_product_id]).first
        co_maker          = params[:co_maker]

        if params[:co_maker_id].present?
          co_maker_member   = Member.where(id: params[:co_maker_id]).first
        end

        pn_number         = params[:pn_number]
        clip_number       = params[:clip_number]
        date_prepared     = params[:date_prepared]
        num_installments  = params[:num_installments]
        term              = params[:term]
        active_loan_ids   = params[:active_loan_ids] || []
        member            = Member.where(id: params[:member_id]).first
        active_loans      = Loan.where(id: active_loan_ids)

        # beneficiary information
        beneficiary_first_name    = params[:beneficiary_first_name]
        beneficiary_middle_name   = params[:beneficiary_middle_name]
        beneficiary_last_name     = params[:beneficiary_last_name]
        beneficiary_date_of_birth = params[:beneficiary_date_of_birth].try(:to_date)
        beneficiary_relationship  = params[:beneficiary_relationship]

        config = {
          user: current_user,
          co_maker: co_maker,
          co_maker_member: co_maker_member,
          loan_product: loan_product,
          member: member,
          pn_number: pn_number,
          clip_number: clip_number,
          date_prepared: date_prepared,
          num_installments: num_installments,
          term: term,
          active_loans: active_loans,
          beneficiary_first_name: beneficiary_first_name,
          beneficiary_middle_name: beneficiary_middle_name,
          beneficiary_last_name: beneficiary_last_name,
          beneficiary_date_of_birth: beneficiary_date_of_birth,
          beneficiary_relationship: beneficiary_relationship
        }

        errors  = ::Loans::ValidateRestructure.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ActiveRecord::Base.transaction do
            loan  = ::Loans::Restructure.new(
                      user: current_user,
                      co_maker: co_maker,
                      co_maker_member: co_maker_member,
                      pn_number: pn_number,
                      clip_number: clip_number,
                      date_prepared: date_prepared,
                      num_installments: num_installments,
                      term: term,
                      member: member,
                      active_loans: active_loans,
                      loan_product: loan_product,
                      beneficiary_first_name: beneficiary_first_name,
                      beneficiary_middle_name: beneficiary_middle_name,
                      beneficiary_last_name: beneficiary_last_name,
                      beneficiary_date_of_birth: beneficiary_date_of_birth,
                      beneficiary_relationship: beneficiary_relationship
                    ).execute!

            render json: { message: "ok", id: loan.id }
          rescue Exception => e
            logger.info e 
            render json: { message: "error", id: member.id }, status: 500
          end
        end
      end

      def approve_adjustment
        adjustment_record = AdjustmentRecord.find(params[:id])

        config  = {
          adjustment_record: adjustment_record,
          user: current_user
        }

        errors  = ::Loans::ValidateApproveAdjustmentRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          adjustment_record = ::Loans::ApproveAdjustmentRecord.new(
                                config: config
                              ).execute!

          render json: { message: "ok" }
        end
      end

      def delete_adjustment
        adjustment_record = AdjustmentRecord.find(params[:id])

        config  = {
          adjustment_record: adjustment_record,
          user: current_user
        }

        errors  = ::Loans::ValidateDeleteAdjustmentRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          adjustment_record.destroy!

          render json: { message: "ok" }
        end
      end

      def new_adjustment
        loan  = Loan.find(params[:id])

        p_principal             = params[:p_principal].try(:to_f)
        p_monthly_interest_rate = params[:p_monthly_interest_rate].try(:to_f)
        p_num_installments      = params[:p_num_installments].try(:to_i)
        p_term                  = params[:p_term]

        config  = {
          loan: loan,
          user: current_user,
          p_principal: p_principal,
          p_monthly_interest_rate: p_monthly_interest_rate,
          p_num_installments: p_num_installments,
          p_term: p_term
        }

        errors  = ::Loans::ValidateReamortize.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          adjustment_record = ::Loans::GenerateReamortizationAdjustment.new(
                                config: config  
                              ).execute!

          render json: { message: "ok", id: adjustment_record.id }
        end
      end

      def delay_amort
        
        amort     = AmortizationScheduleEntry.where(id: params[:id]).first
        user      = current_user
        reason    = params[:reason]
        new_date  = params[:new_date].try(:to_date)
        loan    = Loan.find(amort.loan_id)
      

        config  = {
          amort: amort,
          user: user,
          reason: reason,
          new_date: new_date
        }

        errors  = ::Loans::ValidateDelayAmort.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          loan_data = loan.id
          old_date  = amort.due_date
          loan      = ::Loans::DelayAmort.new(
                        config: config
                      ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} changed amortization #{amort.id} from #{old_date} to #{new_date}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              amortization_schedule_entry_id: amort.id,
              loan_id: loan_data
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


        if errors[:messages].any?
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

        errors = ::Loans::ValidateApprove.new(
          config: config
        ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          loan.update!(status: "processing")

          ProcessApproveLoan.perform_later({
            id: loan.id,
            user_id: current_user.id
          })

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

          project_type_categories = ProjectTypeCategory.where(is_active: true).order("name ASC").map{ |c|
                                      {
                                        id: c.id,
                                        name: c.name,
                                        project_types: c.project_types.where(is_active: true).order("name ASC").map{ |p|
                                          {
                                            id: p.id,
                                            name: p.name
                                          }
                                        }
                                      }
                                    }
          
          transfer_option =  TransferOption.all.order("name ASC").map{ |c|
                                      {
                                        id: c.id,
                                        name: c.name,
                                        bank_transfers: c.bank_transfers.order("name ASC").map{ |p|
                                          {
                                            id: p.id,
                                            name: p.name
                                          }
                                        }
                                      }
                                    }

          render json: { loan: loan, project_type_categories: project_type_categories, transfer_option: transfer_option }
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

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ActiveRecord::Base.transaction do
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
          rescue Exception => e
            render json: { message: "error", id: member.id }, status: 500
          end
        end
      end
      def fraud_save
        loan  = Loan.find(params[:id])
        loan_data = loan.data.with_indifferent_access
        
        loan_data['fraud_data'] = {}
        loan_data['fraud_data']['bar_types'] = params[:bar_types]
        loan_data['fraud_data']['bar_details'] = params[:bar_details]
       
      loan.update(data:loan_data)
      render json: {message: "ok"}
       
      end

      def save
        loan_data = JSON.parse(params[:payload]).with_indifferent_access
        
        #loan_data = JSON.parse(params[:data]).to_h.with_indifferent_access 
        co_maker_profile_picture        = params[:co_maker_profile_picture]
        co_maker_three_profile_picture  = params[:co_maker_three_profile_picture]
        
        config  = {
          loan_data:                      loan_data,
          user:                           current_user,
          co_maker_profile_picture:       co_maker_profile_picture,
          co_maker_three_profile_picture: co_maker_three_profile_picture
        }

        errors  = ::Loans::ValidateSave.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
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

          # UPDATE MEMBER MOBILE NUMBER
          mobile_number = params[:mobile_number]
          member_id = loan_data[:member_id]
          Member.find(member_id).update(mobile_number: mobile_number)

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

        if errors[:messages].any?
          render json: errors, status: 400
        else
          loan  = ::Loans::Reage.new(
                    loan: loan,
                    approved_by: approved_by
                  ).execute!

          render json: { message: "ok", id: loan.id }
        end
      end
      def recompute_restructure
        loan = Loan.where(
                          member_id: params[:id], 
                          loan_product_id: "1c2fcdbd-d60b-402c-b04b-824bb90958d1"
                          ).last
        config = {loan: loan }
        recompute = ::Loans::RecomputeRestructure.new(config: config).execute!

        render json: { message: "ok", id: loan.id }
                          
      end
    end
  end
end
