module Api
  module V1
    module DataStores
      class MemberIdGeneretorsController < ApplicationController
        def create
          branch_id = params[:branch_id]
          user = current_user
          config = {
            branch_id: branch_id,
            user: user
          }  
          @record = ::DataStores::SaveMemberIdGenerators.new(config: config).execute!
          render json: { message: "ok", id: @record.id }
        end
        
        def fetch_members
          
          @member = Member.where(center_id: params[:id], status: "active").map{ |m|
                                                                {
                                                                  id: m.id,
                                                                  name: m.full_name
                                                                }
                                                              

                                                              }
         render json: { members: @member }
        end

        def add_member
          data_store_id = params[:id]
          center_id     = params[:center_id]
          member_id     = params[:member_id]
          member_type   = params[:id_type]
          @config = {
            data_store_id:  data_store_id,
            center_id:      center_id,
            member_id:      member_id,
            member_type:    member_type
              

          }


          raise "jef".inspect         
        end
        
        def contact_person
          @member = Member.find(params[:member_id])
          @member_data = @member.data.with_indifferent_access[:contact_person]
          render json: { message: "ok", id: @member_data, member_name: @member.full_name  }
          

        end

        def add_contact_person
          data_store_id = params[:data][:data_store]
          member_id     = params[:data][:member_id]
          id_type   = params[:data][:id_type]
          contact_person   = params[:data][:contact_person]
          contact_person_number   = params[:data][:contact_person_number]
          @config = {
            data_store_id:  data_store_id,
            member_id:      member_id,
            id_type:    id_type,
            contact_person: contact_person,
            contact_person_number: contact_person_number
          }
          @record = ::DataStores::AddMemberIdGenerators.new(config: @config).execute!
          
        end

        def delete_id_form
          @data_store = DataStore.find(params[:data][:data_store]).destroy!
          render json: { message: "ok"  }
        end

      end
    end
  end
end
