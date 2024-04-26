module Accounting
  class BalanceSheetsController < ApplicationController
    before_action :authenticate_user!

    def index
      @balance_sheets = ReadOnlyDataStore.balance_sheets.where(
                          "meta->>'branch_id' IN (?)",
                          @branches.pluck(:id)
                        ).order(Arel.sql("meta->>'year' DESC, meta->>'month' DESC"))
                        
      @branch_id  = params[:branch_id]

      if params[:date].present? and params[:date][:month].present?
        @month      = params[:date][:month]
      end

      @year       = params[:year]

      if @branch_id.present?
        @balance_sheets = @balance_sheets.where(
          "meta->>'branch_id' = ?",
          @branch_id
        )
      end

      if @month.present?
        @balance_sheets = @balance_sheets.where(
          "meta->>'month' = ?",
          @month
        )
      end

      if @year.present?
        @balance_sheets = @balance_sheets.where(
          "meta->>'year' = ?",
          @year
        )
      end

      @balance_sheets = @balance_sheets.page(params[:page]).per(20)

      @subheader_items = [
        {
          text: "Balance Sheets"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
    end

    def show
      @balance_sheet  = DataStore.balance_sheets.find(params[:id])
      @record         = @balance_sheet
      @meta           = @balance_sheet.meta.with_indifferent_access
      @data           = @balance_sheet.data.with_indifferent_access

      @net_income = @data[:total_income] - @data[:total_expenses]

      # Get statutory funds (beginning)
      ac  = AccountingCode.where(id: Settings.try(:defaults).try(:statutory_fund_id)).try(:first)

      if ac.present?
        sf = @data[:equities].select{ |o| o[:accounting_code][:code] == ac.code }.first

        if sf.present?
          @statutory_funds_beginning = sf
        end
      end

      @subheader_items = [
        {
          is_link: true,
          path: accounting_balance_sheets_path,
          text: "Balance Sheets"
        },
        {
          text: "#{@meta["branch_name"]} #{@meta["year"]}"
        }
      ]

      @subheader_side_actions = []

      if !@balance_sheet.processing?
        @subheader_side_actions << {
          id: "",
          link: accounting_balance_sheet_path(@balance_sheet),
          class: "fa fa-times",
          data: {
            method: :delete,
            confirm: "Are you sure?"
          },
          text: "Delete"
        }
      end
    end

    def destroy
      @balance_sheet  = DataStore.balance_sheets.find(params[:id])
      @balance_sheet.destroy!

      redirect_to accounting_balance_sheets_path
    end
  end
end
