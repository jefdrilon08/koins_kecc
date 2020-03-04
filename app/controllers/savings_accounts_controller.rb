class SavingsAccountsController < ApplicationController
  before_action :authenticate_user!

  def index
    @savings_accounts = MemberAccount.savings.includes(:branch, :member)

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
  end

  def time_deposit_withdrawal
    @savings_account  = MemberAccount.find(params[:id])
    @data_store       = DataStore.find(params[:data_store_id])
  end

  def show
    @savings_account  = MemberAccount.savings.where(id: params[:id]).first

    @account_transactions = AccountTransaction.where(
                              subsidiary_id: @savings_account.id
                            ).order("transacted_at ASC, updated_at ASC")

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
  end
end
