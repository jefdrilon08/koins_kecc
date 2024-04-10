module Api
  module V1
    module DataStores
      class YearEndClosingsController < ActionController::Base
        before_action :authenticate_user!

        def approve
          record  = DataStore.year_end_closings.where(id: params[:id]).first 

          config  = {
            data_store: record,
            user: current_user
          }

          errors  = ::Closing::ValidateApproveYearEndClosing.new(
                      config: config
                    ).execute!

          if errors[:full_messages].any?
            render json: errors, status: 400
          else
            record.update!(status: "processing")
            ProcessApproveYearEnd.perform_later(
              id: record.id,
              user_id: current_user.id
            )
            #::Closing::ApproveYearEndClosing.new(
            #  config: config
            #).execute!
          end
        end

        def queue
          @data_store_type  = "YEAR_END_CLOSING"
          @record           = DataStore.year_end_closings.where(id: params[:id]).first 

          @errors = ::Closing::ValidateYearEndGenerate.new(
                      config: {
                        branch: Branch.where(id: params[:branch_id]).first,
                        closing_date: params[:closing_date].try(:to_date)
                      }
                    ).execute!

          if @errors[:full_messages].any?
            render json: @errors, status: 400
          elsif @record.blank?
            @branch       = Branch.find(params[:branch_id])
            @closing_date = params[:closing_date].to_date

            settings  = Settings.accounting_fund_year_end_closing_entries

            if settings.present?
              # KMBA
              settings.each do |o|
                accounting_fund = AccountingFund.find(o.accounting_fund_id)

                @record = DataStore.create!(
                            meta: {
                              branch_id: @branch.id,
                              branch_name: @branch.name,
                              closing_date: @closing_date,
                              year: @closing_date.year,
                              data_store_type: @data_store_type,
                              progress: 0,
                              accounting_fund: accounting_fund
                            },
                            data: {
                              status: "processing"
                            }
                          )

                @record.update!(status: "processing")

                args = {
                  id: @record.id,
                  data_store_type: @data_store_type,
                  user_id: current_user.id,
                  accounting_fund_id: o.accounting_fund_id
                }

                ProcessYearEndClosing.perform_later(args)
              end
            else
              # KCOOP
              @record = DataStore.create!(
                          meta: {
                            branch_id: @branch.id,
                            branch_name: @branch.name,
                            closing_date: @closing_date,
                            year: @closing_date.year,
                            data_store_type: @data_store_type,
                            progress: 0
                          },
                          data: {
                            status: "processing"
                          }
                        )

              @record.update!(status: "processing")

              args = {
                id: @record.id,
                data_store_type: @data_store_type,
                user_id: current_user.id
              }

              ProcessYearEndClosing.perform_later(args)
            end

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
