class PrintController < ApplicationController 
  before_action :authenticate_user!

  def print
    file  = params[:filename]

    @data = JSON.parse(File.read("#{Rails.root}/tmp/#{file}")).with_indifferent_access

    if @data[:type] == "accounting_entry"
      @accounting_entry_data  = @data[:data]
      @deposit_collection = @data[:data]
      
      render "print/accounting_entry", layout: "plain"
    elsif @data[:type] == "deposit_collection_accounting_entry"
      @accounting_entry_data  = @data[:data]

      render "print/accounting_entry", layout: "plain"
    elsif @data[:type] == "member_share"
      @member_share_data  = @data[:data]

      render "print/member_share", layout: "plain"
    elsif @data[:type] == "billing"
      @billing  = @data[:data]

      render "print/billing", layout: "plain"
    elsif @data[:type] == "membership_payment_collection"
      @membership_payment_collection  = @data[:data]

      render "print/membership_payment_collection", layout: "plain"
    elsif @data[:type] == "trial_balance"
      @trial_balance  = @data[:data]

      render "print/trial_balance", layout: "plain"
    elsif @data[:type] == "general_ledger"
      @general_ledger = @data[:data]

      render "print/general_ledger", layout: "plain"
    elsif @data[:type] == "wp"
      @billing  = @data[:data]

      render "print/wp", layout: "plain"
    elsif @data[:type] == "book"
      @book = @data[:data]

      render "print/book", layout: "plain"
    elsif @data[:type] == "deposit_collection"
      @deposit_collection = @data[:data]
      
      render "print/deposit_collection", layout: "plain"
    elsif @data[:type] == "insurance_fund_transfer_collection"
      @insurance_fund_transfer_collection = @data[:data]

      render "print/insurance_fund_transfer_collection", layout: "plain"
    elsif @data[:type] == "time_deposit_collection"
      @deposit_collection = @data[:data]

      render "print/deposit_collection", layout: "plain"
    elsif @data[:type] == "withdrawal_collection"
      @withdrawal_collection = @data[:data]

      render "print/withdrawal_collection", layout: "plain"
    elsif @data[:type] == "withdrawal_request"
      @withdrawal_request = @data[:data]

      render "print/withdrawal_request", layout: "plain"
    else
      raise "Invalid type #{@data[:type]}"
    end
  end
end
