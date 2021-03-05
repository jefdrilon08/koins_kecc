class MonthlyAccountingCodeSummariesController < ApplicationController
  before_action :authenticate_user!

  def index
    @monthly_accounting_code_summaries  = ReadOnlyMonthlyAccountingCodeSummary.select("*")
                                            .includes([:accounting_code, :branch])
                                            .where(branch_id: @branches.pluck(:id))

    @accounting_codes = ReadOnlyAccountingCode.all

    @branch           = ReadOnlyBranch.find_by_id(params[:branch_id])
    @accounting_code  = ReadOnlyAccountingCode.find_by_id(params[:accounting_code_id])
    @year             = params[:year].try(:to_i)
    @month            = params[:month].try(:to_i)

    if @branch.present?
      @monthly_accounting_code_summaries = @monthly_accounting_code_summaries.where(branch_id: @branch.id)
    end

    if @year.present? and @year > 0
      @monthly_accounting_code_summaries = @monthly_accounting_code_summaries.where(year: @year)
    end

    if @month.present? and @month >= 1 and @month <= 12
      @monthly_accounting_code_summaries = @monthly_accounting_code_summaries.where(month: @month)
    end

    if @accounting_code.present?
      @monthly_accounting_code_summaries = @monthly_accounting_code_summaries.where(accounting_code_id: @accounting_code.id)
    end

    @monthly_accounting_code_summaries  = @monthly_accounting_code_summaries
                                            .order("monthly_accounting_code_summaries.updated_at DESC")
                                            .page(params[:page])
                                            .per(LIST_PAGE_SIZE)

    @subheader_items = [
      { text: "Monthly Accountng Code Summaries" }
    ]

    @subheader_side_actions = [
      { id: "btn-new", link: "#", class: "fa fa-plus", text: "New Monthly" }
    ]

    @payload = {
      urlCreate: "#{ENV['BACKEND_API_URL']}/api/v2/monthly_accounting_code_summaries/create",
      userId: current_user.id,
      xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
    }
  end
end
