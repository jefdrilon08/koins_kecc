module Api
  module V1
    module DataStores
      class IcprController < ActionController::Base
        before_action :authenticate_user!

        def fetch
          @record = DataStore.icpr.where(id: params[:id]).first

          if @record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            render json: @record
          end
        end

        def queue
          @data_store_type  = params[:data_store_type] || "ICPR"
          @year             = params[:year]
          @branch_id        = params[:branch_id]
          @branch           = Branch.where(id: @branch_id).first
          @record           = DataStore.icpr.where("meta->>'branch_id' = ? AND meta->>'year' = ?", @branch_id, @year).first 

          errors  = ::DataStores::ValidateIcprQueue.new(
                      config: {
                        year: @year,
                        record: @record,
                        branch: @branch
                      }
                    ).execute!

          if errors[:full_messages].any?
            render json: errors, status: 400
          else
            if @record.blank?
              @record = DataStore.create!(
                          meta: {
                            data_store_type: @data_store_type,
                            year: @year,
                            branch_id: @branch.id,
                            branch_name: @branch.name,
                            branch: {
                              id: @branch.id,
                              name: @branch.name
                            }
                          },
                          data: {
                            status: "processing",
                            year: @year,
                            branch: {
                              id: @branch.id,
                              name: @branch.name
                            }
                          }
                        )
              elsif !@record.processing? and !@record.approved?
                @record.update!("processing")
            end

            args = {
              id: @record.id,
              data_store_type: @data_store_type,
              year: @year,
              branch_id: @branch.id,
              user_id: current_user.id
            }

            ProcessIcpr.perform_later(args)

            render json: { message: "ok", id: @record.id }
          end
        end

        def approve
          data_store  = DataStore.find(params[:id])
        
          config  = {
            data_store: data_store,
            user: current_user
          }

          errors  = ::Icpr::ValidateApprove.new(
                      config: config
                    ).execute!
          
          if errors[:messages].any?
            render json: errors, status: 400
          else
            data_store.update!(status: "processing")

            args  = {
              id: data_store.id,
              user_id: current_user.id
            }

            ProcessApproveIcpr.perform_later(args)

            render json: { message: "ok" }
          end
        end

        def set_rate
          data_store            = DataStore.find(params[:id])
          equity_interest_rate  = params[:equity_interest_rate].try(:to_f)
          savings_rate          = params[:savings_rate].try(:to_f)
          cbu_rate              = params[:cbu_rate].try(:to_f)

          config = {
            data_store: data_store,
            equity_interest_rate: equity_interest_rate,
            savings_rate: savings_rate,
            cbu_rate: cbu_rate,
            user: current_user
          }

          ::Icpr::SetRate.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end
    end
  end
end
