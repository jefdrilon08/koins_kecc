module Api
  module V1
    module DataStores
      class MembersInGoodStandingController < ActionController::Base
        before_action :authenticate_user!

        def fetch

          record  = DataStore.members_in_good_standing.where(id: params[:id]).first
        
          if record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
          
            records = record.data.with_indifferent_access[:records]
           
            record.data["officers"] = records.select{ |o|
                                        o[:officer].present? 
                                      }.map{ |o| o[:officer] }.uniq


            record.data["centers"] = records.select{ |o|
                                        o[:center].present? 
                                      }.map{ |o| o[:center] }.uniq
                                      
             if params[:center_id].present?
              records = records.select{ |o|
                          o[:center][:id] == params[:center_id]
                        }
            end

            if params[:officer_id].present?
              records = records.select{ |o|
                          o[:officer].present?
                        }.select{ |o|
                          o[:officer][:id] == params[:officer_id]
                        }
            end

            record.data["records"] = records
            render json: record
          end
          
        end

        def queue
          @data_store_type  = params[:data_store_type] || "MEMBERS_IN_GOOD_STANDING"
          @year             = params[:year]
          @branch_id        = params[:branch_id]
          @branch           = Branch.where(id: @branch_id).first
          @record           = DataStore.members_in_good_standing.where("meta->>'branch_id' = ? AND meta->>'year' = ?", @branch_id, @year).first 

          errors  = ::DataStores::ValidateMembersInGoodStandingQueue.new(
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
           
            ProcessMigs.perform_later(args)

            render json: { message: "ok", id: @record.id }
          end
        end

      end
    end
  end
end
