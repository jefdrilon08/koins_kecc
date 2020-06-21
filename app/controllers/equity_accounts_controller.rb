class EquityAccountsController < ApplicationController
  before_action :authenticate_user!

  def index
    @equity_accounts = ReadOnlyMemberAccount
      .equities
      .includes(:branch, :member)
      .where(branch_id: @branches.pluck(:id))

    if params[:q].present?
      @q  = params[:q]

      @equity_accounts = @equity_accounts.where(
                            "upper(first_name) LIKE :q OR upper(last_name) LIKE :q OR upper(identification_number) LIKE :q",
                            q: "%#{@q.upcase}%"
                          )
    end

    if params[:subtype].present?
      @subtype  = params[:subtype]

      @equity_accounts = @equity_accounts.where(account_subtype: @subtype)
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @equity_accounts = @equity_accounts.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center = Center.find(params[:center_id])
      @equity_accounts = @equity_accounts.where(center_id: @center.id)
    end
 
    @equity_accounts = @equity_accounts.page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items = [
      {
        text: "Accounts"
      },
      {
        text: "Equity"
      }
    ]

    @subheader_side_actions = []
  end

  def show
    @equity_account       = ReadOnlyMemberAccount.equities.find(params[:id])
    @member               = @equity_account.member
    @account_transactions = ReadOnlyAccountTransaction.where(
                              subsidiary_id: @equity_account.id
                            ).order("transacted_at ASC, updated_at ASC")

    @subheader_items = [
      {
        text: "Accounts"
      },
      {
        is_link: true,
        path: equity_accounts_path,
        text: "Equity"
      },
      {
        is_link: true,
        path: member_path(@member),
        text: "#{@member.full_name}"
      },
      {
        text: "#{@equity_account.account_subtype}"
      }
    ]

    @subheader_side_actions = [
      {
        class: "",
        link: "#",
        text: "Balance: #{helpers.number_to_currency(@equity_account.balance, unit: '')}"
      }
    ]
  end
end
