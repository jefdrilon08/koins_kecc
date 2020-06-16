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

      @subheader_items = [
        {
          text: "Books"
        },
        {
          is_link: true,
          path: "/accounting/books/#{@accounting_entry.book.downcase}",
          text: "#{@accounting_entry.book.upcase}"
        }
      ]

      if @accounting_entry.pending?
        @subheader_items << {
          text: "[PENDING]"
        }
      else
        @subheader_items << {
          text: "#{@accounting_entry.reference_number} - #{@accounting_entry.book}"
        }
      end

      @subheader_side_actions = [
        {
          id: "btn-print",
          class: "fa fa-print",
          link: "#",
          text: "Print",
          data: {
            id: "#{@accounting_entry.id}"
          }
        }
      ]

      if @accounting_entry.pending?
        @subheader_side_actions << {
          link: accounting_accounting_entry_form_path(id: @accounting_entry.id, book: @accounting_entry.book, accounting_fund_id: @accounting_entry.accounting_fund_id),
          class: "fa fa-pencil-alt",
          text: "Edit"
        }

        @subheader_side_actions << {
          link: accounting_delete_accounting_entry_path(@accounting_entry.id),
          data: {
            method: :delete,
            confirm: "Are you sure?"
          },
          text: "Delete",
          class: "fa fa-times"
        }

        if @accounting_entry.book == "JVB" and helpers.sbk_mis_user
          @subheader_side_actions << {
            id: "btn-approve",
            link: "#",
            data: {
              id: "#{@accounting_entry.id}"
            },
            class: "fa fa-check"
          }
        elsif helpers.sbk_bk_mis_user
          @subheader_side_actions << {
            id: "btn-approve",
            link: "#",
            text: "Approve",
            data: {
              id: "#{@accounting_entry.id}"
            },
            class: "fa fa-check"
          }
        end
      end
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
