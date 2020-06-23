class SavingsAccountsController < ApplicationController
  before_action :authenticate_user!

  def index
    @savings_accounts = ReadOnlyMemberAccount
      .savings
      .includes(:branch, :member)
      .where(branch_id: @branches.pluck(:id))

    if params[:q].present?
      @q  = params[:q]

      @savings_accounts = @savings_accounts.where(
                            "upper(first_name) LIKE :q OR upper(last_name) LIKE :q OR upper(identification_number) LIKE :q",
                            q: "%#{@q.upcase}%"
                          )
    end

    if params[:subtype].present?
      @subtype  = params[:subtype]

      @savings_accounts = @savings_accounts.where(account_subtype: @subtype)
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @savings_accounts = @savings_accounts.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center = Center.find(params[:center_id])
      @savings_accounts = @savings_accounts.where(center_id: @center.id)
    end

    @savings_accounts = @savings_accounts.page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items = [
      {
        text: "Accounts"
      },
      {
        text: "Savings"
      }
    ]

    @subheader_side_actions = []
  end

  def time_deposit_withdrawal
    @savings_account  = ReadOnlyMemberAccount.find(params[:id])
    @member           = @savings_account.member
    @data_store       = ReadOnlyDataStore.find(params[:data_store_id])

    @subheader_items = [
      {
        text: "Accounts"
      },
      {
        is_link: true,
        path: savings_accounts_path,
        text: "Savings"
      },
      {
        is_link: true,
        path: member_path(@member),
        text: "#{@member.full_name}"
      },
      {
        text: "#{@savings_account.account_subtype}"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-print-withdrawal-request",
        class: "fa fa-print",
        link: "#",
        text: "Print"
      }
    ]

    @payload = { id: @data_store.id }
  end

  def show
    @savings_account  = ReadOnlyMemberAccount.savings.find(params[:id])
    @member           = @savings_account.member

    @account_transactions = ReadOnlyAccountTransaction.where(
                              subsidiary_id: @savings_account.id
                            ).order("transacted_at ASC, updated_at ASC")

    
    @account_transactions = @account_transactions.page(params[:page]).per(LIST_PAGE_SIZE)

    if @savings_account.time_deposit?
      @withdrawal_requests  = ::MemberAccounts::TimeDeposit::FetchWithdrawalRequests.new(
                                config: {
                                  member_account: @savings_account
                                }
                              ).execute!

      @pending_requests = @withdrawal_requests[:records].select{ |o|
                            o[:status] == "pending"
                          }

      @approved_requests  = @withdrawal_requests[:records].select{ |o|
                              o[:status] == "approved"
                            }

      @lock_in_period = ::MemberAccounts::TimeDeposit::FetchLockInPeriod.new(
                          config: {
                            member_account: @savings_account
                          }
                        ).execute!

      @autorenewals = DataStore.time_deposit_autorenewal.where(
                        "meta->'member_account'->>'id' = ?",
                        @savings_account.id
                      )
    end

    @subheader_items = [
      {
        text: "Accounts"
      },
      {
        is_link: true,
        path: savings_accounts_path,
        text: "Savings"
      },
      {
        is_link: true,
        path: member_path(@member),
        text: "#{@member.full_name}"
      },
      {
        text: "#{@savings_account.account_subtype}"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-sync-maintaining-balance",
        class: "fa fa-sync",
        link: "#",
        text: "Sync Maintaining Balance"
      },
      {
        class: "",
        link: "#",
        text: "Balance: #{helpers.number_to_currency(@savings_account.balance, unit: '')}"
      },
      {
        class: "",
        link: "#",
        text: "Maintaining Balance: #{helpers.number_to_currency(@savings_account.maintaining_balance, unit: '')}"
      }
    ]

    @payload = { id: @savings_account.id }
  end
end
