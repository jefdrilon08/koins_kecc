module Loans
  class Approve
    include ActionView::Helpers::NumberHelper
    def initialize(config:)
      super()

      @loan = config[:loan]
      @user = config[:user]

      @member           = @loan.member
      @loan_product     = @loan.loan_product
      @num_installments = @loan.num_installments
      @term             = @loan.term
      @project_type_id = @loan.project_type_id



      @member       = @loan.member
      @member_data  = @member.data.with_indifferent_access
      @branch       = @member.branch

      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!

      # Main settings for this loan product
      @settings = nil

      @transaction_type = "deposit"
      @date_paid        = @current_date

      Settings.loan_products.each do |s|
        if s.loan_product_id == @loan_product.id
          @settings = s
        end
      end

      if @settings.blank?
        raise "Settings not foud for loan product #{@loan_product.id}: #{@loan_product.name}. Please check production.yml"
      end

      # Setup loan cycle
      @loan_cycles            = @member_data[:loan_cycles] || []
      @entry_point_loan_cycle = @member_data[:entry_point_loan_cycle] || 0
      if @project_type_id.present?
        @project_type = ProjectType.find(@project_type_id)
      end
    end

    def execute!
      post_accounting_entry!

      perform_deposits!

      if @loan.data["sms_fee_available"].present? || @loan.data["sms_fee_available"] == false 
        @member_data[:sms_record] = {
          loan: @loan.id,
          loan_maturity: @loan.maturity_date,
          timestamp: Time.now,
          sms_validation: true,
          sms_rec: true
        }
      end

      if @loan_cycles.blank?
        @loan_cycles  = [
          {
            loan_product_id: @loan_product.id,
            cycle: 1
          }
        ]

        if @loan_product.is_entry_point
          @entry_point_loan_cycle = @entry_point_loan_cycle + 1
        end
      else
        if @loan_product.is_entry_point
          @entry_point_loan_cycle = @entry_point_loan_cycle + 1
        end

        found = false
        @loan_cycles.each_with_index do |c, i|
          if c[:loan_product_id] == @loan_product.id
            @loan_cycles[i][:cycle] = c[:cycle] + 1
            found = true
          end
        end

        if !found
          @loan.cycle = 1
          @loan_cycles << {
            loan_product_id: @loan_product.id,
            cycle: @loan.cycle
          }
        end
      end

      # Updat member data
      @member_data[:loan_cycles]            = @loan_cycles
      @member_data[:entry_point_loan_cycle] = @entry_point_loan_cycle

      if @project_type_id.present?
        @member_data[:project_type] = [
            { project_type_id: @project_type_id,
              project_type_category_id: @project_type.project_type_category_id,
              details: {
                project_type: @project_type.name,
                project_type_category: @project_type.project_type_category.name ,
                latitude_data: 0.0,
                longtitude_data: 0.0
              }

            }

        ]

      end

      @member.update!(data: @member_data)


      amorts = @loan.amortization_schedule_entries.order("due_date DESC")

      # setup max_active_date
      max_active_date = amorts.first.due_date

      # setup maturity_date
      maturity_date = amorts.last.due_date

      @loan.update!(
        status: "active",
        date_approved: @current_date,
        max_active_date: max_active_date,
        maturity_date: maturity_date
      )

      @loan
    end

    private

    def perform_deposits!
      @settings.deductions.each do |s_deduction|
        deduction_type  = s_deduction.deduction_type

        if s_deduction.name == "KMBA Membership Fee"
          @date_paid = @loan.date_released
        end

        if deduction_type == "share_capital_fee"

            if @loan.data["share_capital_available"].nil? || @loan.data["share_capital_available"] == false
              total_member_shares = MemberShare.where("member_id = ? and  certificate_for = ? and is_void is null",@member.id, "KCOOP").sum(:number_of_shares)
              @share_capital_deposit = Settings.defaults["share_capital_deposits"].last["regular_share_deposits"].select{ |a|   @loan.principal.to_f >= a["min_amount"]  and @loan.principal.to_f <= a["max_amount"]}

              share_capital_account = MemberAccount.where(member_id: @member.id, account_subtype: "Share Capital").last

              partial_number_of_share =  total_member_shares +  @share_capital_deposit.last["number_of_share"]

              if s_deduction.max_share < partial_number_of_share
                share_avail =  s_deduction.max_share  - total_member_shares
                @need_total_share_to_avail = share_avail
              else
                @need_total_share_to_avail = @share_capital_deposit.last["number_of_share"].to_f
              end
              #raise partial_number_of_share.inspect
              if total_member_shares <= s_deduction.max_share.to_i
                @total_share_paid =  @need_total_share_to_avail.to_f * s_deduction.amount.to_f

              end

              acc_data = {
                          is_withdraw_payment: false,
                          is_fund_transfer: false,
                          is_interest: false,
                          is_adjustment: false,
                          is_for_exit_age: false,
                          is_for_loan_payments: false,
                          accounting_entry_reference_number: nil,
                          beginning_balance: "0.0",
                          ending_balance: "0.0"
                        }

              if s_deduction["skip_sc"].present?
                number_of_sharecap = MemberAccount.where(account_subtype: "Share Capital").last.balance.to_f
                save_account_transaction = AccountTransaction.create!(
                                                                  subsidiary_id: share_capital_account.id,
                                                                  subsidiary_type: "MemberAccount",
                                                                  amount: @total_share_paid,
                                                                  transaction_type: "deposit",
                                                                  transacted_at: @current_date,
                                                                  status: "approved",
                                                                  data: acc_data
                                                                  )
                save_account_transaction.save!
                ::MemberAccounts::Rehash.new(member_account: share_capital_account).execute!
              else
                if (@member_data[:entry_point_loan_cycle].to_i + 1.to_i ).to_i > 1

                  save_account_transaction = AccountTransaction.create!(
                                                                  subsidiary_id: share_capital_account.id,
                                                                  subsidiary_type: "MemberAccount",
                                                                  amount: @total_share_paid,
                                                                  transaction_type: "deposit",
                                                                  transacted_at: @current_date,
                                                                  status: "approved",
                                                                  data: acc_data
                                                                  )
                  save_account_transaction.save!
                  ::MemberAccounts::Rehash.new(member_account: share_capital_account).execute!
                end
              end
          end
        elsif deduction_type == "membership_fee"
          membership_payment_record = MembershipPaymentRecord.paid.where(
                                        membership_type: s_deduction.membership_type,
                                        member_id: @loan.member.id
                                      ).first


          if membership_payment_record.blank?
            MembershipPaymentRecord.create!(
              member: @loan.member,
              membership_type: s_deduction.membership_type,
              membership_name: s_deduction.meta.membership_name,
              amount: s_deduction.amount,
              status: "paid",
              date_paid: @date_paid
            )

            # Check if we already have loans (for old accounts transferred form 1.0)
            if @member.loans.active_or_paid.count > 0 && @member_data[:restoration_records].last.nil? && @member.insurance_status != "pending"
              @member_data[:recognition_date] = @member.loans.active_or_paid.order("date_approved ASC").first.date_approved
            else
              @member_data[:recognition_date] = @date_paid
            end
          end

          @member.update!(insurance_status: "inforce")
        elsif deduction_type == "deposit"
          if @member.member_type != "GK"

            if s_deduction.special_loan == "true" #for special loan Insurance
              if @loan.data.with_indifferent_access[:advance_insurance_available] == false
                offset          = s_deduction.meta.offset
                accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
                name            = accounting_code.name
                code            = accounting_code.code
                amount          = 0.00
                val             = s_deduction.meta.value

                # Base value on accounting entry
                entry = @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] == accounting_code.id }.first

                if entry.present?
                  amount = entry["amount"].to_f.round(2)
                end

                 if amount > 0

                  member_account  = MemberAccount.where(
                                    member_id: @member.id,
                                    account_type: s_deduction.meta.account_type,
                                    account_subtype: s_deduction.meta.account_subtype
                                  ).first

                  account_transaction = AccountTransaction.new(
                                          subsidiary_id: member_account.id,
                                          subsidiary_type: "MemberAccount",
                                          amount: amount,
                                          transaction_type: @transaction_type,
                                          transacted_at: @date_paid,
                                          status: "approved",
                                          data: {
                                            is_withdraw_payment: false,
                                            is_fund_transfer: false,
                                            is_interest: false,
                                            is_adjustment: false,
                                            is_for_exit_age: false,
                                            is_for_loan_payments: false,
                                            accounting_entry_reference_number: nil,
                                            beginning_balance: 0.00,
                                            ending_balance: 0.00,
                                            data: {}
                                          }
                                        )

                  # Compute beginning and ending balance
                  account_transaction.data[:beginning_balance]  = member_account.balance.round(2)
                  account_transaction.data[:ending_balance]     = (member_account.balance + amount).round(2)

                  # For equity amount computation
                  if member_account.account_subtype == Settings.life
                    if member_account.data.nil?
                      # For New Loaner
                      member_account.data = { equity_value: (amount / 2).round(2) }
                      member_account.save!

                      account_transaction.data[:equity_value] = (amount / 2).round(2)
                    else
                      # For Reloaner
                      member_account_data = member_account.data.with_indifferent_access
                      equity_value = member_account_data[:equity_value]
                      member_account_data[:equity_value] = ((amount / 2) + equity_value).round(2)
                      member_account.update!(data: member_account_data)

                      account_transaction.data[:equity_value] = ((amount / 2) + equity_value).round(2)
                    end

                    # For Equity Value deposit transaction
                    ev_account = @member.member_accounts.where(account_subtype:"Equity Value").first

                    if ev_account.present?
                      ev_balance = ev_account.balance

                      ev_account_transaction  = AccountTransaction.new(
                                                subsidiary_id: ev_account.id,
                                                subsidiary_type: "MemberAccount",
                                                amount: (amount / 2).round(2),
                                                transaction_type: "deposit",
                                                transacted_at: @date_paid,
                                                status: "approved",
                                                data: {
                                                  is_withdraw_payment: false,
                                                  is_fund_transfer: false,
                                                  is_interest: false,
                                                  is_adjustment: false,
                                                  is_for_exit_age: false,
                                                  is_for_loan_payments: false,
                                                  accounting_entry_reference_number: nil,
                                                  beginning_balance: ev_balance.to_f,
                                                  ending_balance: (ev_balance.to_f + (amount /2)).round(2)
                                                }
                                              )

                      new_ev_balance = (ev_balance.to_f + (amount / 2)).round(2)
                      ev_account.update(
                        balance: new_ev_balance
                      )

                      ev_account_transaction.save!
                    end
                  end

                  # Update account balance
                  new_balance = (member_account.balance + amount).round(2)
                  member_account.update!(
                    balance: new_balance
                  )
                  account_transaction.save!
                end
              end
            end #end for special loan for insurance

            if s_deduction.meta.algo == "term_multiplier_for_second_cycle_onwards"

              if @loan.data.with_indifferent_access[:advance_insurance_available] == false
                offset          = s_deduction.meta.offset
                accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
                name            = accounting_code.name
                code            = accounting_code.code
                amount          = 0.00
                val             = s_deduction.meta.value

                # Base value on accounting entry
                entry = @loan.data["accounting_entry"]["credit_journal_entries"].select{ |o| o["accounting_code_id"] == accounting_code.id }.first

                if entry.present?
                  amount = entry["amount"].to_f.round(2)
                end
#                multiplier  = @num_installments
#
#                loan_cycle  = @loan_cycles.select{ |c| c[:cycle] >= 1 and c[:loan_product_id] == @loan_product.id }.first
#                if loan_cycle.present?
#                  if @term == "weekly"
#                  elsif @term == "monthly"
#                    multiplier  = (multiplier * 4.3333333).ceil.to_i
#                  elsif @term == "semi-monthly"
#                    # weird unique rule for 12 semi-monthly
#                    if @num_installments ==  12
#                      multiplier  = 12.5 * 2
#                    elsif @num_installments == 6
#                      multiplier  = 15
#                    else
#                      multiplier  = multiplier * 2
#                    end
#                  else
#                    raise "Invalid term #{@term}"
#                  end
#
#                  amount  = val * (multiplier + offset)
#                else
#                  amount  = val
#                end #end loan cycle present

                #### DEPOSIT TRANSACTION ####

                if amount > 0

                  member_account  = MemberAccount.where(
                                    member_id: @member.id,
                                    account_type: s_deduction.meta.account_type,
                                    account_subtype: s_deduction.meta.account_subtype
                                  ).first

                  account_transaction = AccountTransaction.new(
                                          subsidiary_id: member_account.id,
                                          subsidiary_type: "MemberAccount",
                                          amount: amount,
                                          transaction_type: @transaction_type,
                                          transacted_at: @date_paid,
                                          status: "approved",
                                          data: {
                                            is_withdraw_payment: false,
                                            is_fund_transfer: false,
                                            is_interest: false,
                                            is_adjustment: false,
                                            is_for_exit_age: false,
                                            is_for_loan_payments: false,
                                            accounting_entry_reference_number: nil,
                                            beginning_balance: 0.00,
                                            ending_balance: 0.00,
                                            data: {}
                                          }
                                        )

                  # Compute beginning and ending balance
                  account_transaction.data[:beginning_balance]  = member_account.balance.round(2)
                  account_transaction.data[:ending_balance]     = (member_account.balance + amount).round(2)

                  # For equity amount computation
                  if member_account.account_subtype == Settings.life
                    if member_account.data.nil?
                      # For New Loaner
                      member_account.data = { equity_value: (amount / 2).round(2) }
                      member_account.save!

                      account_transaction.data[:equity_value] = (amount / 2).round(2)
                    else
                      # For Reloaner
                      member_account_data = member_account.data.with_indifferent_access
                      equity_value = member_account_data[:equity_value]
                      member_account_data[:equity_value] = ((amount / 2) + equity_value).round(2)
                      member_account.update!(data: member_account_data)

                      account_transaction.data[:equity_value] = ((amount / 2) + equity_value).round(2)
                    end

                    # For Equity Value deposit transaction
                    ev_account = @member.member_accounts.where(account_subtype:"Equity Value").first

                    if ev_account.present?
                      ev_balance = ev_account.balance

                      ev_account_transaction  = AccountTransaction.new(
                                                subsidiary_id: ev_account.id,
                                                subsidiary_type: "MemberAccount",
                                                amount: (amount / 2).round(2),
                                                transaction_type: "deposit",
                                                transacted_at: @date_paid,
                                                status: "approved",
                                                data: {
                                                  is_withdraw_payment: false,
                                                  is_fund_transfer: false,
                                                  is_interest: false,
                                                  is_adjustment: false,
                                                  is_for_exit_age: false,
                                                  is_for_loan_payments: false,
                                                  accounting_entry_reference_number: nil,
                                                  beginning_balance: ev_balance.to_f,
                                                  ending_balance: (ev_balance.to_f + (amount /2)).round(2)
                                                }
                                              )

                      new_ev_balance = (ev_balance.to_f + (amount / 2)).round(2)
                      ev_account.update(
                        balance: new_ev_balance
                      )

                      ev_account_transaction.save!
                    end
                  elsif member_account.account_subtype == Settings.clip || member_account.account_subtype == Settings.hiip
                    account_transaction.data[:data] = {
                                                        id: @loan.id,
                                                        principal: @loan.principal,
                                                        interest: @loan.interest,
                                                        first_date_of_payment: @loan.first_date_of_payment,
                                                        maturity_date: @loan.maturity_date,
                                                        original_maturity_date: @loan.original_maturity_date,
                                                        accounting_entry_id: nil,
                                                        journal_entry_id: nil,
                                                        amount: amount,
                                                        loan_product_id: @loan.loan_product.id,
                                                        loan_product_name: @loan.loan_product.name,
                                                        member_id: @loan.member.id,
                                                        date_approved: @current_date,
                                                        date_released: @loan.date_released,
                                                        reference_number: nil,
                                                        book: @loan.data.with_indifferent_access[:accounting_entry][:book],
                                                        member_account_id: member_account.id,
                                                        term: @term,
                                                        num_installments: @num_installments,
                                                        account_transaction_id: nil,
                                                        status: nil
                                                      }
                  end

                  # Update account balance
                  new_balance = (member_account.balance + amount).round(2)
                  member_account.update!(
                    balance: new_balance
                  )

                  account_transaction.save!
                end
                #### DEPOSIT TRANSACTION
              end
            end #s_deduction.meta.algo
          end #gk
        end
      end
    end

    def post_accounting_entry!
      accounting_entry_data = @loan.data.with_indifferent_access[:accounting_entry]

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: {
                              id: nil,
                              accounting_entry_data: accounting_entry_data,
                              user: @user
                            }
                          ).execute!

      accounting_entry  = ::Accounting::AccountingEntries::Approve.new(
                            config: {
                              accounting_entry: accounting_entry,
                              user: @user
                            }
                          ).execute!

      # Update reference number
      data  = @loan.data.with_indifferent_access
      data[:accounting_entry][:reference_number] = accounting_entry.reference_number

      @loan.update!(
        data: data
      )
    end
    def send_sms!
      member = Member.find(@loan.member_id)
      content = "Good Day! #{member.full_name.upcase}, Your Loan has been approved with Loan Reference Number: #{@loan.pn_number} amounting to #{number_to_currency(@loan.principal,unit: "")} and the first date of payment is #{@loan.first_date_of_payment.to_fs(:long)}  THIS IS A TEST MESSAGE ONLY"
        if member.mobile_number.present?


          config = {
            mobile_number: member.mobile_number,
            content: content
          }

          #SmsBlast::Send.new(config: config).execute!
        end
      end
    end

end
