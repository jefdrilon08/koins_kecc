module Accounting
  class AccountingEntriesController < ApplicationController
    before_action :authenticate_user!

    def index
      @accounting_entries = AccountingEntry.selcet("*").order("date_prepared DESC")
    end

    def show
      @accounting_entry = AccountingEntry.find(params[:id])

      @activity_logs  = ActivityLog.where(
                          "data ->> 'accounting_entry_id' = ?",
                          @accounting_entry.id
                        ).order("created_at DESC")
    end

    def form
      @subheader_items = [
        {
          text: "Accounting"
        },
        {
          is_link: true,
          path: "/accounting/books/#{params[:book].downcase}",
          text: "#{params[:book].upcase}"
        },
        {
          text: "Accounting Entry Form"
        }
      ]

      @subheader_side_actions = [
      ]

      defaultBranch = nil

      if Settings.try(:defaults).try(:default_branch).present?
        s = Settings.try(:defaults).try(:default_branch)

        defaultBranch = {
          id: s.id,
          name: s.name
        }
      end

      @payload = {
        id: params[:id],
        book: params[:book],
        accountingFundId: params[:accounting_fund_id] || "",
        defaultBranch: defaultBranch
      }
    end

    def destroy
      @accounting_entry = AccountingEntry.find(params[:id])

      if @accounting_entry.pending?
        book  = @accounting_entry.book

        @accounting_entry.destroy!
        
        redirect_to "/accounting/books/#{book.downcase}"
      else
        redirect_to accounting_accounting_entry_path(@accounting_entry.id)
      end
    end
  end
end
