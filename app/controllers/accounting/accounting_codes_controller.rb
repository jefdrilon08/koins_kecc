module Accounting
  class AccountingCodesController < ApplicationController
    before_action :authenticate_user!
    before_action :load_accounting_code!, only: [:edit, :update, :show, :destroy]

    def index
      @accounting_codes = AccountingCode.select("*").order("code ASC")
    end

    def new
      @accounting_code  = AccountingCode.new
    end

    def create
      @accounting_code  = AccountingCode.new(accounting_code_params)

      if @accounting_code.save
        redirect_to accounting_accounting_code_path(@accounting_code)
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @accounting_code.update(accounting_code_params)
        redirect_to accounting_accounting_code_path(@accounting_code)
      else
        render :edit
      end
    end

    def show
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
