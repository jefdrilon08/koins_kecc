module Api
  module V1
    module DataStores
      class ForWriteoffController < ApplicationController
        before_action :authenticate_user!

        def fetch
          record  = DataStore.for_writeoff.where(id: params[:id]).first
        
          if record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            

            render json: record
          end
        end

        def queue
         
          @data_store_type  = params[:data_store_type] || "FOR_WRITEOFF"
          @year             = params[:year]
          @branch_id        = params[:branch_id]
          @number_of_years  = params[:select_number_year]
          @branch           = Branch.where(id: @branch_id).first
          @record           = DataStore.for_writeoff.where("meta->>'branch_id' = ? AND meta->>'year' = ?", @branch_id, @year).first
          errors  = ::DataStores::ValidateForWriteoffQueue.new(
                      config: {
                        year: @year,
                        record: @record,
                        branch: @branch,
                        select_number_year: @number_of_years
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
                              number_of_years: @number_of_years,
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
                number_of_years: @number_of_years,
                branch_id: @branch.id,
                user_id: current_user.id
              }
             
              ProcessForWriteoff.perform_later(args)
              render json: { message: "ok", id: @record.id }
            end
        end
      end
    end
  end
end
