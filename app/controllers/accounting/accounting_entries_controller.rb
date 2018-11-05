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
