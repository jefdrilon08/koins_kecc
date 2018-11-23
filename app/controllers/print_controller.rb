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
    else
      raise "Invalid type #{@data[:type]}"
    end
  end
end
