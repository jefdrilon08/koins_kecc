class PrintController < ApplicationController 
  before_action :authenticate_user!

  def print
    file  = params[:filename]

    @data = JSON.parse(File.read("#{Rails.root}/tmp/#{file}")).with_indifferent_access

    if @data[:type] == "accounting_entry"
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
    else
      raise "Invalid type #{@data[:type]}"
    end
  end
end
