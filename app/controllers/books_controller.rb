class BooksController < ApplicationController
  before_action :authenticate_user!

  def excel
    type = params[:type]

    if type == "book"
      render json: {download_url: "#{books_download_excel_path(start_date: params[:start_date], end_date: params[:end_date],branch: params[:branch_id],book: params[:book], accounting_fund: params[:accounting_fund_id] )}"}
    end
  end

  def books_download_excel
      books_excel = ::Reports::DownloadBooksExcel.new(
      start_date: params[:start_date],
      end_date: params[:end_date],
      books: params[:book],
      branch: params[:branch],
      accounting_fund: params[:accounting_fund]
      ).execute!

      if Settings.activate_microinsurance
        if params[:accounting_fund].present?
          accounting_fund = AccountingFund.find(params[:accounting_fund])
          filename= "#{accounting_fund.name} - #{params[:book]}.xlsx"
        else
          filename= "#{params[:book]}.xlsx"  
        end   
      else
        filename= "#{params[:book]}.xlsx"
      end

      books_excel.serialize "#{Rails.root}/tmp/#{filename}"
      send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}" , type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  
  end
end

