module Api
  module V1
    module DataStores
      class MonthlyNewAndResignedController < ApiController
        before_action :authenticate_user!
        

        def fetch
          record  = DataStore.monthly_new_and_resigned.where(id: params[:id]).first
          if record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            
            records_new= record.data.with_indifferent_access[:new_members]
            records_resigned = record.data.with_indifferent_access[:resigned_members]
          
            # Get officers
            new_officers_rec = records_new.select{ |o| 
                                        o[:officer].present? 
                                      }.map{ |o| o[:officer] }.uniq

            resigned_officers_rec =  records_resigned.select{ |o| 
                                        o[:officer].present? 
                                      }.map{ |o| o[:officer] }.uniq
            record.data["officers"] = new_officers_rec + resigned_officers_rec
            
            #get centers
             new_members_center = records_new.select{ |o| 
                                        o[:center].present? 
                                      }.map{ |o| o[:center] }.uniq
            resigned_members_center = records_resigned.select{ |o| 
                                        o[:center].present? 
                                      }.map{ |o| o[:center] }.uniq    

            record.data["centers"]= new_members_center + resigned_members_center

            # center filter
            if params[:center_id].present?
              records_new = records_new.select{ |o|
                          o[:center][:id] == params[:center_id]
                        }
              records_resigned = records_resigned.select{ |o|
                          o[:center][:id] == params[:center_id]
                        }
            end
            #officer filter
            if params[:officer_id].present?
              records_new = records_new.select{ |o|
                          o[:officer].present?
                        }.select{ |o|
                          o[:officer][:id] == params[:officer_id]
                        }

              records_resigned = records_resigned.select{ |o|
                          o[:officer].present?
                        }.select{ |o|
                          o[:officer][:id] == params[:officer_id]
                        }
            end

            record.data["records"]={new_members: {},resigned_members:{}}
            record.data["records"][:new_members]= records_new
            record.data["records"][:resigned_members]= records_resigned
            render json: record
          end
        end
        @at_rec = nil
        def resolution_update
          @record  = DataStore.find(params[:id]).data.with_indifferent_access
          @record["resolution_number"] = params[:reso]
          
           
          
          
          #resigned member
          member_ids_res = @record["resigned_members"].map { |member| member["id"] }
          member_details_res = Member.where(id: member_ids_res)
          
          #new member

          member_ids = @record["new_members"].map { |member| member["id"] }
          member_details = Member.where(id: member_ids)
          
          member_details.each_with_index do |member|
            member_data = member.data.with_indifferent_access

            
            member_data['new_reso'] = {}
            member_data['new_reso']['date_of_membership'] = member.date_of_membership
            member_data['new_reso']['resolution_number'] = params[:reso]
            
            
            member.update(data: member_data)
          end
           
            member_details_res.each_with_index do |member_res|
            member_data_res = member_res.data.with_indifferent_access
              
            
            member_data_res['resigned_reso'] = {}
            member_data_res['resigned_reso']['date_of_membership'] = member_res.date_of_membership
            member_data_res['resigned_reso']['resolution_number'] = params[:reso]
            
            
            member_res.update(data: member_data_res)
          end 
          DataStore.find(params[:id]).update!(data: @record)
          render json: {message: "ok"}
        end 
        
        
        def queue
          
          @data_store_type  = "MONTHLY_NEW_AND_RESIGNED"
          @as_of            = params[:as_of].to_date
          @month            = @as_of.month
          @year             = @as_of.year
          @branch           = Branch.find(params[:branch_id])
          @as_of            = Date.new(@year, @month, -1)

          @record = DataStore.monthly_new_and_resigned.where(
                      "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                      @branch.id,
                      @as_of
                    ).first

          if @record.blank?
            @record = DataStore.create!(
                        meta: {
                          branch_id: @branch.id,
                          branch_name: @branch.name,
                          resolution_number: '',
                          branch: {
                            id: @branch.id,
                            name: @branch.name
                          },
                          month: @month,
                          year: @year,
                          as_of: @as_of,
                          data_store_type: @data_store_type
                        },
                        data: {
                          status: "processing"
                        }
                      )
          end

          @record.update!(status: "processing")

          args  = {
            data_store_id: @record.id,
            user_id: current_user.id,
            branch_id: @branch.id,
            year: @year,
            month: @month
          }

          ProcessMonthlyNewAndResigned.perform_later(args)

          render json: { message: "ok" }
        end
      end
    end
  end
end
