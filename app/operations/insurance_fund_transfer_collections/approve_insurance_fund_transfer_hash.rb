module InsuranceFundTransferCollections
  class ApproveInsuranceFundTransferHash
    def initialize(config:)
      @config                     = config
      @reference_number           = @config[:insurance_fund_transfer][:reference_num]
      @is_interest                = @config[:insurance_fund_transfer][:is_interest]
      @date_paid                  = @config[:date_paid]
      @insurance_fund_transfer    = @config[:insurance_fund_transfer]
      @user                       = @config[:user]
      @particular                 = @config[:particular]
      @amount                     = @insurance_fund_transfer[:amount].try(:to_f).round(2)
      @transaction_type           = "deposit"
      @member_account             = MemberAccount.find(@insurance_fund_transfer[:member_account_id])
      @account_subtype            = @config[:insurance_fund_transfer][:account_subtype]

      if @reference_number.present?
        @account_transaction_api = AccountTransaction.new(
          subsidiary_id: @member_account.id,
          subsidiary_type: "MemberAccount",
          amount: @amount,
          transaction_type: @transaction_type,
          transacted_at: @date_paid,
          status: "approved",
          external_ref: @reference_number
        )

        @data_api = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: false,
          is_adjustment: false,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          beginning_balance: 0.00,
          ending_balance: 0.00,
          payment_tpye: "gcash",

        }
      elsif @is_interest.present?
        @account_transaction_api = AccountTransaction.new(
          subsidiary_id: @member_account.id,
          subsidiary_type: "MemberAccount",
          amount: @amount,
          transaction_type: @transaction_type,
          transacted_at: @date_paid,
          status: "approved"
        )

        @data_api = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: true,
          is_adjustment: false,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          beginning_balance: 0.00,
          ending_balance: 0.00
        }
      else
        @account_transaction  = AccountTransaction.new(
                                  subsidiary_id: @member_account.id,
                                  subsidiary_type: "MemberAccount",
                                  amount: @amount,
                                  transaction_type: @transaction_type,
                                  transacted_at: @date_paid,
                                  status: "approved"
                                )
        @data = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: false,
          is_adjustment: false,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          beginning_balance: 0.00,
          ending_balance: 0.00        }
      end
    end

    def execute!
      if @reference_number.present?
        @data_api[:beginning_balance] = @member_account.balance.round(2)
        @data_api[:ending_balance]    = (@data_api[:beginning_balance] + @amount).round(2)

        # For equity amount computation
        if @member_account.account_subtype == Settings.life
          if @member_account.data.present?
            @member_account_data = @member_account.data.with_indifferent_access

            equity_value = @member_account_data[:equity_value].to_f

            if equity_value.present?
              @data_api[:equity_value]                = ((@amount.to_f / 2) + equity_value).round(2)
              @member_account_data[:equity_value] = ((@amount.to_f / 2) + equity_value).round(2)

              @member_account.update!(data: @member_account_data)
            end
          end

          # For Equity Value deposit transaction
          member     = @member_account.member
          ev_account = member.member_accounts.where(account_subtype:"Equity Value").first

          if ev_account.present?
            ev_balance = ev_account.balance

            account_transaction  = AccountTransaction.new(
                                      subsidiary_id: ev_account.id,
                                      subsidiary_type: "MemberAccount",
                                      amount: (@amount / 2).round(2),
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
                                        payment_tpye: "gcash",
                                        accounting_entry_reference_number: nil,
                                        beginning_balance: ev_balance.to_f,
                                        ending_balance: (ev_balance.to_f + (@amount /2)).round(2)
                                      }
                                    )

            new_balance = (ev_balance.to_f + (@amount / 2)).round(2)
            ev_account.update(
              balance: new_balance
            )

            account_transaction.save!
          end
        end

        # Update account balance
        new_balance = (@member_account.balance + @amount).round(2)
        @member_account.update(
          balance: new_balance
        )

        @account_transaction_api.data = @data_api

        @account_transaction_api.save!
      elsif @is_interest.present?

        if @account_subtype == "Life Insurance Fund"
          # For Equity Value deposit transaction
          member     = @member_account.member
          ev_account = member.member_accounts.where(account_subtype:"Equity Value").first

          if ev_account.present?
            ev_balance = ev_account.balance

            account_transaction  = AccountTransaction.new(
                                      subsidiary_id: ev_account.id,
                                      subsidiary_type: "MemberAccount",
                                      amount: @amount,
                                      transaction_type: "deposit",
                                      transacted_at: @date_paid,
                                      status: "approved",
                                      data: {
                                        is_withdraw_payment: false,
                                        is_fund_transfer: false,
                                        is_interest: true,
                                        is_adjustment: false,
                                        is_for_exit_age: false,
                                        is_for_loan_payments: false,
                                        accounting_entry_reference_number: nil,
                                        beginning_balance: 0.00,
                                        ending_balance: 0.00                                      }
                                    )

            account_transaction.save!

            ev_id  = account_transaction.subsidiary_id
            # raise ev_id.inspect
            MemberAccounts::Rehash.new(member_account:MemberAccount.find(ev_id)).execute!
          end
        else
          member     = @member_account.member
          rf_account = member.member_accounts.where(account_subtype:"Retirement Fund").first

          if rf_account.present?
            ev_balance = rf_account.balance

            account_transaction  = AccountTransaction.new(
                                      subsidiary_id: rf_account.id,
                                      subsidiary_type: "MemberAccount",
                                      amount: @amount,
                                      transaction_type: "deposit",
                                      transacted_at: @date_paid,
                                      status: "approved",
                                      data: {
                                        is_withdraw_payment: false,
                                        is_fund_transfer: false,
                                        is_interest: true,
                                        is_adjustment: false,
                                        is_for_exit_age: false,
                                        is_for_loan_payments: false,
                                        accounting_entry_reference_number: nil,
                                        beginning_balance: 0.00,
                                        ending_balance: 0.00                                      }
                                    )

            account_transaction.save!

            rf_id  = account_transaction.subsidiary_id
            # raise rf_id.inspect
            MemberAccounts::Rehash.new(member_account:MemberAccount.find(rf_id)).execute!
          end

        end
      else
        # Compute beginning and ending balance
        @data[:beginning_balance] = @member_account.balance.round(2)
        @data[:ending_balance]    = (@data[:beginning_balance] + @amount).round(2)

        # For equity amount computation
        if @member_account.account_subtype == Settings.life
          if @member_account.data.present?
            @member_account_data = @member_account.data.with_indifferent_access

            equity_value = @member_account_data[:equity_value].to_f

            if equity_value.present?
              @data[:equity_value]                = ((@amount.to_f / 2) + equity_value).round(2)
              @member_account_data[:equity_value] = ((@amount.to_f / 2) + equity_value).round(2)

              @member_account.update!(data: @member_account_data)
            end
          end

          # For Equity Value deposit transaction
          member     = @member_account.member
          ev_account = member.member_accounts.where(account_subtype:"Equity Value").first

          if ev_account.present?
            ev_balance = ev_account.balance

            account_transaction  = AccountTransaction.new(
                                      subsidiary_id: ev_account.id,
                                      subsidiary_type: "MemberAccount",
                                      amount: (@amount / 2).round(2),
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
                                        ending_balance: (ev_balance.to_f + (@amount /2)).round(2)
                                      }
                                    )

            new_balance = (ev_balance.to_f + (@amount / 2)).round(2)
            ev_account.update(
              balance: new_balance
            )

            account_transaction.save!
          end
        end

        # Update account balance
        new_balance = (@member_account.balance + @amount).round(2)
        @member_account.update(
          balance: new_balance
        )

        @account_transaction.data = @data

        @account_transaction.save!
      end
    end
  end
end
