module Api
  module V1
    module Adjustments
      class MoratoriumsController < ApplicationController
        before_action :authenticate_user!

        def process_moratorium
          member_moratorium_id = params[:id]
          member_moratorium    = MemberMoratorium.where(id: params[:id]).first

          config = {
            member_moratorium: member_moratorium,
            user: current_user
          }

          validator = ::Adjustments::Moratoriums::ValidateProcess.new(
                        config: config
                      )

          validator.execute!

          if validator.errors[:messages].any?
            render json: validator.errors, status: 400
          else
            member_moratorium.update!(status: "processing")

            ProcessMemberMoratorium.perform_later({
              id: member_moratorium_id,
              user_id: current_user.id
            })

            render json: { message: "ok" }
          end
        end

        def delete
          moratorium  = MemberMoratorium.find(params[:id])

          if !moratorium.pending?
            raise "Invalid record #{moratorium.id}"
          end

          moratorium.destroy!

          render json: { message: "ok" }
        end

        def create
          branch  = Branch.where(id: params[:branch_id]).first
          center  = Center.where(id: params[:center_id]).first
          member  = Member.where(id: params[:member_id]).first

          date_initialized  = params[:date_initialized]
          number_of_days    = params[:number_of_days]

          config = {
            branch: branch,
            center: center,
            member: member,
            date_initialized: date_initialized,
            number_of_days: number_of_days,
            user: current_user
          }

          validator = ::Adjustments::Moratoriums::ValidateCreate.new(
                        config: config
                      )

          validator.execute!

          if validator.errors[:messages].any?
            render json: validator.errors, status: 400
          else
            record  = ::Adjustments::Moratoriums::Create.new(
                        config: config
                      ).execute!

            render json: { id: record.id }
          end
        end
      end
    end
  end
end
