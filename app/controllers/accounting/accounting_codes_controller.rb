module Accounting
  class AccountingCodesController < ApplicationController
    before_action :authenticate_user!
    before_action :load_accounting_code!, only: [:edit, :update, :show, :destroy]
    
    #######
    def excel
    data = ::Accounting::AccountingCodes::DownloadExcelChartOfAccounts.new.execute!
    filename= "chart_of_accounts.xlsx"
    data.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end

    def download
      data      = ::Accounting::AccountingCodes::GenerateHashList.new.execute!
      filename  = "accounting-codes-#{Time.now.to_i}.json"
      path      = "#{Rails.root}/tmp"

      file  = ::Utils::WriteToJsonFile.new(
                config: {
                  filename: filename,
                  path: path,
                  data: data
                }
              ).execute!

      send_file file, filename: filename, type: "text/json"
    end

    def index
      @accounting_codes = AccountingCode.select("*").order("code ASC")

      @subheader_items = [
        {
          text: "Accounting"
        },
        {
          text: "Chart of Accounts"
        }
      ]
      if helpers.is_mis_user?
        @subheader_side_actions = [
          {
            link: accounting_download_accounting_codes_path,
            class: "fa fa-download",
            text: "Download"
          },
          {
            link: "/accounting/print_chart_of_accounts",
            class: "fa fa-print",
            text: "Print"
          },
          {
            link: new_accounting_accounting_code_path,
            class: "fa fa-plus",
            text: "New Accounting Code"
          },
          {
            link: "/accounting/download_excel_chart_of_accounts",
            class: "fa fa-download",
            text: "Excel"
          }
        ]
      end
    end

    def print
      @accounting_codes = AccountingCode.select("*").order("code ASC")

      render "print", layout: "plain"
    end

    def new
      @accounting_code  = AccountingCode.new

      @subheader_items = [
        {
          text: "Accounting"
        },
        {
          is_link: true,
          path: accounting_accounting_codes_path,
          text: "Chart of Accounts"
        },
        {
          text: "New Accounting Code"
        }
      ]

      @subheader_side_actions = []
    end

    def create
      @accounting_code  = AccountingCode.new(accounting_code_params)

      if @accounting_code.save
        redirect_to accounting_accounting_code_path(@accounting_code)
      else
        @subheader_items = [
          {
            text: "Accounting"
          },
          {
            is_link: true,
            path: accounting_accounting_codes_path,
            text: "Chart of Accounts"
          },
          {
            text: "New Accounting Code"
          }
        ]

        render :new
      end
    end

    def edit
      @subheader_items = [
        {
          text: "Accounting"
        },
        {
          is_link: true,
          path: accounting_accounting_codes_path,
          text: "Chart of Accounts"
        },
        {
          text: "Edit: #{@accounting_code}"
        }
      ]

      @subheader_side_actions = []
    end

    def update
      if @accounting_code.update(accounting_code_params)
        redirect_to accounting_accounting_code_path(@accounting_code)
      else
        @subheader_items = [
          {
            text: "Accounting"
          },
          {
            is_link: true,
            path: accounting_accounting_codes_path,
            text: "Chart of Accounts"
          },
          {
            text: "Edit: #{@accounting_code}"
          }
        ]

        render :edit
      end
    end

    def show
      @subheader_items = [
        {
          text: "Accounting"
        },
        {
          is_link: true,
          path: accounting_accounting_codes_path,
          text: "Chart of Accounts"
        },
        {
          text: "Accounting Code: #{@accounting_code}"
        }
      ]
      
      if helpers.is_mis_user?
        @subheader_side_actions = [
          {
            link: edit_accounting_accounting_code_path(@accounting_code),
            class: "fa fa-pencil-alt",
            text: "Edit"
          },
          {
            link: accounting_accounting_code_path(@accounting_code),
            data: { method: :delete, confirm: "Are you sure?" },
            class: "fa fa-times",
            text: "Delete"
          }
        ]
      end
    end

    def destroy
      @accounting_code.destroy!

      redirect_to accounting_accounting_codes_path
    end

    private

    def load_accounting_code!
      @accounting_code  = AccountingCode.find(params[:id])
    end

    def accounting_code_params
      params.require(:accounting_code).permit!
    end
  end
end
