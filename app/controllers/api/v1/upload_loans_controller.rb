module Api
  module V1
    class UploadLoansController < ApiController
      before_action :authenticate_user!

      def preview
        file = params[:file]
        return render json: { errors: { full_messages: ["File is required"] } }, status: 400 if file.blank?

        result = ::Loans::ParseUploadFile.new(file: file).execute!

        if result[:errors].any?
          render json: { errors: { full_messages: result[:errors] } }, status: 400
        else
          render json: { loans: result[:loans], total_count: result[:loans].size, columns: result[:columns] }
        end
      end

      def save
        loans_payload = JSON.parse(params[:loans_payload]).with_indifferent_access
        return render json: { errors: { full_messages: ["No loan data provided"] } }, status: 400 if loans_payload[:loans].blank?

        results = { saved: [], errors: [] }

        ActiveRecord::Base.transaction do
          loans_payload[:loans].each_with_index do |raw_loan, index|
            loan_data = build_loan_data(raw_loan.with_indifferent_access)
            config    = build_config(loan_data)

            errors = ::Loans::ValidateSave.new(config: config).execute!
            if errors[:full_messages].any?
              results[:errors] << { row: index + 1, member_id: loan_data[:member_id], messages: errors[:full_messages] }
              next
            end

            loan = ::Loans::Save.new(config: config).execute!

            apply_first_payment(loan, loan_data)
            apply_amortization_overrides(loan, loan_data)
            apply_paid_installments(loan, loan_data)

            # Validate before approving
            approve_config = { loan: loan, user: current_user }
            approve_errors = ::Loans::ValidateApprove.new(config: approve_config).execute!

            if approve_errors[:messages].any?
              results[:errors] << { row: index + 1, member_id: loan_data[:member_id], messages: approve_errors[:messages] }
              next
            end

            loan.update!(status: "processing")
            ProcessApproveLoan.perform_later({ id: loan.id, user_id: current_user.id })

            create_activity_log(loan)

            results[:saved] << {
              row:                index + 1,
              loan_id:            loan.id,
              member_id:          loan.member_id,
              amortization_count: loan.amortization_schedule_entries.count
            }
          end

          raise ActiveRecord::Rollback, "Validation errors found" if results[:errors].any?
        end

        if results[:errors].any?
          render json: { errors: results[:errors] }, status: 400
        else
          render json: { message: "Loans uploaded successfully", saved_count: results[:saved].size, loans: results[:saved] }
        end
      end

      def amortization
        loan    = Loan.find(params[:loan_id])
        entries = loan.amortization_schedule_entries.order(:due_date).map do |e|
          {
            due_date:          e.due_date,
            principal:         e.principal,
            interest:          e.interest,
            amount_due:        e.amount_due,
            principal_paid:    e.principal_paid,
            interest_paid:     e.interest_paid,
            principal_balance: e.principal_balance,
            interest_balance:  e.interest_balance
          }
        end

        render json: {
          loan: {
            id:                    loan.id,
            principal:             loan.principal,
            interest:              loan.interest,
            term:                  loan.term,
            num_installments:      loan.num_installments,
            first_date_of_payment: loan.first_date_of_payment,
            maturity_date:         loan.maturity_date
          },
          entries: entries
        }
      end

      private

      def build_loan_data(loan_data)
        loan_data[:data] = default_data_structure(loan_data).merge(loan_data[:data].to_h.stringify_keys)
        loan_data[:data]["co_maker_one"] = ensure_co_maker_one(loan_data[:data]["co_maker_one"])
        loan_data[:data]["voucher"]      = build_voucher(loan_data)
        loan_data[:data]["co_makers"]    = build_co_makers(loan_data)
        loan_data
      end

      def default_data_structure(loan_data)
        {
          "business_permit_available"   => false,
          "advance_insurance_available" => false,
          "share_capital_available"     => false,
          "service_fee_available"       => false,
          "sms_fee_available"           => false,
          "clip_number"                 => "",
          "co_makers"                   => [],
          "co_maker_two"                => "",
          "co_maker_three"              => "",
          "co_maker_one"                => blank_co_maker_one,
          "payment_type"                => "",
          "sub_type"                    => "",
          "clip_beneficiary"            => {
            "first_name"    => "",
            "middle_name"   => "",
            "last_name"     => "",
            "date_of_birth" => "",
            "relationship"  => ""
          },
          "voucher" => build_voucher(loan_data)
        }
      end

      def build_voucher(loan_data)
        {
          "bank"                              => "",
          "bank_check_number"                 => loan_data[:bank_check_number].to_s,
          "check_number"                      => loan_data[:check_number].to_s,
          "payee"                             => "",
          "date_requested"                    => loan_data[:date_requested].to_s,
          "date_of_check"                     => loan_data[:date_of_check].to_s,
          "bank_transaction_reference_number" => "",
          "particular"                        => ""
        }
      end

      def ensure_co_maker_one(value)
        value.is_a?(Hash) ? blank_co_maker_one.merge(value.stringify_keys) : blank_co_maker_one
      end

      def blank_co_maker_one
        { "id" => "", "first_name" => "", "middle_name" => "", "last_name" => "" }
      end

      def build_co_makers(loan_data)
        co_makers = []

        [:first_co_maker_id, :second_co_maker_id, :third_co_maker_id].each do |key|
          id = loan_data[key].presence
          next unless id

          member = Member.find_by(id: id)
          next unless member

          co_makers << {
            "id"   => member.id,
            "name" => member.full_name
          }
        end

        co_makers
      end

      def build_config(loan_data)
        {
          loan_data:                      loan_data,
          payment_type:                   loan_data[:payment_type].presence || "cash",
          sub_type:                       loan_data[:sub_type].presence || "",
          user:                           current_user,
          co_maker_profile_picture:       nil,
          co_maker_three_profile_picture: nil
        }
      end

      def apply_first_payment(loan, loan_data)
        return unless loan_data[:first_date_of_payment].present?

        loan.update!(first_date_of_payment: loan_data[:first_date_of_payment])
        ::Loans::AmortizeDates.new(config: { loan: loan }).execute!
        loan.reload
        loan.update!(original_maturity_date: loan.maturity_date)
      end

      def apply_amortization_overrides(loan, loan_data)
        return unless loan_data[:amortization_overrides].present?

        entries = loan.amortization_schedule_entries.order(:due_date).to_a
        loan_data[:amortization_overrides].each do |override|
          override = override.with_indifferent_access
          entry    = entries[override[:installment_number].to_i - 1]
          next unless entry && override[:due_date].present?
          entry.update!(due_date: override[:due_date].to_date)
        end
      end

      def apply_paid_installments(loan, loan_data)
        paid_count = loan_data[:paid_installments].to_i
        return if paid_count <= 0

        entries    = loan.amortization_schedule_entries.order(:due_date).to_a
        paid_count = [paid_count, entries.size].min

        total_principal_paid = 0
        total_interest_paid  = 0

        entries.first(paid_count).each do |entry|
          entry.update!(
            principal_paid:    entry.principal,
            interest_paid:     entry.interest,
            principal_balance: 0,
            interest_balance:  0,
            is_paid:           true
          )
          total_principal_paid += entry.principal
          total_interest_paid  += entry.interest
        end

        # Update the loan balances to reflect paid installments
        loan.update!(
          principal_paid:    total_principal_paid,
          interest_paid:     total_interest_paid,
          principal_balance: loan.principal - total_principal_paid,
          interest_balance:  loan.interest  - total_interest_paid
        )
      end

      def create_activity_log(loan)
        ActivityLog.create!(
          content:       "#{current_user.full_name} uploaded loan #{loan.id} via bulk upload",
          activity_type: "creation",
          data:          { user_id: current_user.id, loan_id: loan.id }
        )
      end
    end
  end
end