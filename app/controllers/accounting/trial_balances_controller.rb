module Accounting
  class TrialBalancesController < ApplicationController
    before_action :authenticate_user!

    def index
      current_date  = Date.today

      @start_date = Date.new(current_date.year, current_date.month, 1)
      @end_date   = Date.new(current_date.year, current_date.month, -1)

      @accounting_funds = AccountingFund.all

      @trial_balances = DataStore.select(:id, :meta, :status, :updated_at).trial_balances.where(
                          "meta->>'branch_id' IN (?)",
                          @branches.pluck(:id)
                        ).order("status DESC, updated_at DESC")

      # Filter
      @f_branch_id          = params[:f_branch_id]
      @f_start_date         = params[:f_start_date].try(:to_date)
      @f_end_date           = params[:f_end_date].try(:to_date)
      @f_accounting_fund_id = params[:f_accounting_fund_id]

      if @f_branch_id.present?
        @trial_balances = @trial_balances.where(
                            "meta->>'branch_id' = ?",
                            @f_branch_id
                          )
      end

      if @f_start_date.present? and @f_end_date.present? and @f_start_date < @f_end_date
        @trial_balances = @trial_balances.where(
                            "DATE(meta->>'start_date') >= ? AND DATE(meta->>'end_date') <= ?",
                            @f_start_date,
                            @f_end_date
                          )
      end

      if @f_accounting_fund_id.present?
        @trial_balances = @trial_balances.where(
                            "meta->>'accounting_fund_id' = ?",
                            @f_accounting_fund_id
                          )
      end

      @trial_balances = @trial_balances.page(params[:page]).per(20)

      @subheader_items = [
        {
          text: "Trial Balances"
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

      @payload = {
        urlCreate: "#{ENV['BACKEND_API_URL']}/api/v1/trial_balances/create",
        userId: current_user.id,
        xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
      }
    end

    def show
      @trial_balance  = DataStore.find(params[:id])

      if @trial_balance.processing?
        redirect_to accounting_trial_balances_path
      else
        @start_date           = @trial_balance.meta["start_date"].to_date.strftime("%B %d, %Y")
        @end_date             = @trial_balance.meta["end_date"].to_date.strftime("%B %d, %Y")
        @branch_name          = @trial_balance.meta["branch_name"]
        @updated_at           = @trial_balance.updated_at.strftime("%B %d, %Y %H:%M")
        @accounting_fund_name = @trial_balance.meta["accounting_fund_name"]
        @prepared_by          = "#{@trial_balance.meta["user"]["last_name"]}, #{@trial_balance.meta["user"]["first_name"]}"

        @subheader_items = [
          { is_link: true, path: accounting_trial_balances_path, text: "Trial Balances" },
          { text: "#{@branch_name} #{@start_date} to #{@end_date} (Updated: #{@updated_at})" }
        ]

        if @accounting_fund_name.present?
          @subheader_items << { text: @accounting_fund_name }
        end

        @subheader_items << { text: "Prepared by: #{@prepared_by}" }


        @subheader_side_actions = [
          {
            id: "btn-delete",
            link: "#",
            class: "fa fa-times",
            text: "Delete"
          }
        ]

        @payload = {
          id: @trial_balance.id,
          urlDelete: "#{ENV['BACKEND_API_URL']}/api/v1/trial_balances/delete",
          userId: current_user.id,
          xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
        }
      end
    end
  end
end
