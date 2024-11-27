module Accounting
  class GeneralLedgersController < ApplicationController
    before_action :authenticate_user!

    def print
      general_ledger  = DataStore.general_ledgers.find(params[:id])

      excel = ::Accounting::GeneralLedgers::BuildExcel.new(
                data: general_ledger.data
              ).execute!

      send_data excel.to_stream.read, type: "application/xlsx", filename: "general-ledger.xlsx"
    end

    def index
      current_date  = Date.today

      @start_date = Date.new(current_date.year, current_date.month, 1)
      @end_date   = Date.new(current_date.year, current_date.month, -1)

      @accounting_funds = ReadOnlyAccountingFund.all

      @general_ledgers = DataStore.select(:id, :meta, :status, :updated_at).general_ledgers.where(
                          "meta->>'branch_id' IN (?)",
                          @branches.pluck(:id)
                        ).order("status DESC, updated_at DESC")

      # Filter
      @f_branch_id          = params[:f_branch_id]
      @f_start_date         = params[:f_start_date].try(:to_date)
      @f_end_date           = params[:f_end_date].try(:to_date)
      @f_accounting_fund_id = params[:f_accounting_fund_id]

      if @f_branch_id.present?
        @general_ledgers = @general_ledgers.where(
                            "meta->>'branch_id' = ?",
                            @f_branch_id
                          )
      end

      if @f_start_date.present? and @f_end_date.present? and @f_start_date < @f_end_date
        @general_ledgers = @general_ledgers.where(
                            "DATE(meta->>'start_date') >= ? AND DATE(meta->>'end_date') <= ?",
                            @f_start_date,
                            @f_end_date
                          )
      end

      if @f_accounting_fund_id.present?
        @general_ledgers = @general_ledgers.where(
                            "meta->>'accounting_fund_id' = ?",
                            @f_accounting_fund_id
                          )
      end
      
      @general_ledgers = @general_ledgers.page(params[:page]).per(20)

      @subheader_items = [
        {
          text: "General Ledgers"
        }
      ]

      @subheader_side_actions = [
      ]

      @payload = {
        urlCreate: "#{ENV['BACKEND_API_URL']}/api/v1/general_ledgers/create",
        userId: current_user.id,
        xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
      }
    end

    def show
      @general_ledger  = DataStore.find(params[:id])

      if @general_ledger.processing?
        redirect_to accounting_general_ledgers_path
      else
        @start_date           = @general_ledger.meta["start_date"].to_date.strftime("%B %d, %Y")
        @end_date             = @general_ledger.meta["end_date"].to_date.strftime("%B %d, %Y")
        @branch_name          = @general_ledger.meta["branch_name"]
        @updated_at           = @general_ledger.updated_at.strftime("%B %d, %Y %H:%M")
        @accounting_fund_name = @general_ledger.meta["accounting_fund_name"]
        @prepared_by          = "#{@general_ledger.meta["user"]["last_name"]}, #{@general_ledger.meta["user"]["first_name"]}"

        @subheader_items = [
          { is_link: true, path: accounting_general_ledgers_path, text: "General Ledgers" },
          { text: "#{@branch_name} #{@start_date} to #{@end_date} (Updated: #{@updated_at})" }
        ]

        if @accounting_fund_name.present?
          @subheader_items << { text: @accounting_fund_name }
        end

        @subheader_items << { text: "Prepared by: #{@prepared_by}" }

          
        @subheader_side_actions = [
          {
            id: "btn-printpdf",
            link: "/print?type=general_ledger&id=#{@general_ledger.id}",
            class: "fa fa-print",
            text: "PDF"
          },
 
          {
            id: "btn-print",
            link: "/accounting/general_ledgers/#{@general_ledger.id}/print",
            class: "fa fa-print",
            text: "Print"
          },
          {
            id: "btn-tb",
            link: "/accounting/trial_balances/#{@general_ledger.id}",
            class: "fa fa-arrow-left",
            text: "Trial Balance"
          },
          {
            id: "btn-delete",
            link: "#",
            class: "fa fa-times",
            text: "Delete"
          }
        ]

        @payload = {
          id: @general_ledger.id,
          urlDelete: "#{ENV['BACKEND_API_URL']}/api/v1/general_ledgers/delete",
          userId: current_user.id,
          xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
        }
      end
    end
  end
end
