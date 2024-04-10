module Api
  module V1
    module DataStores
      class ForWriteoffController < ActionController::Base
        before_action :authenticate_user!

        def fetch
          record  = DataStore.for_writeoff.where(id: params[:id]).first
        
          if record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            records = record.data.with_indifferent_access[:records]

            record.data["maturity_year"] = records.select{ |o|
                                        o[:maturity_date].present? 
                                      }.map{ |o| o[:maturity_date].to_date.year }.uniq

            record.data["centers"] = records.select{ |o|
                                        o[:center].present? 
                                      }.map{ |o| o[:center] }.uniq
              
              if params[:center_id].present?
                records = records.select{ |o|
                            o[:center][:id] == params[:center_id]
                          }
              end
              
              if params[:year].present?
                records = records.select{|o|
                  o[:maturity_date].to_date.year.to_s == params[:year]} 
              end

              record.data["records"] = records
              render json: record
          end
        end

        def queue
         
          @data_store_type  = params[:data_store_type] || "FOR_WRITEOFF"
          @year             = params[:year]
          @branch_id        = params[:branch_id]
          @number_of_years  = params[:number_year]
          @branch           = Branch.where(id: @branch_id).first
          @record           = DataStore.for_writeoff.where("meta->>'branch_id' = ? AND meta->>'year' = ?", @branch_id, @year).first
          
          errors  = ::DataStores::ValidateForWriteoffQueue.new(
                      config: {
                        year: @year,
                        record: @record,
                        number_year: @number_of_years,
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
                            },
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
