module Api
  module V1
    class PrintController < ApplicationController
      before_action :authenticate_user!

      def generate_file
        type  = params[:type]

        if type == "accounting_entry"
          accounting_entry  = AccountingEntry.find(params[:id])
          filename          = "accounting-entry-#{Time.now.to_i}.json"

          data  = ::Print::BuildAccountingEntry.new(
                    accounting_entry: accounting_entry
                  ).execute!

          json_data = {
            type: type,
            data: data
          }

          File.open("#{Rails.root}/tmp/#{filename}", "w") do |f|
            f.write(JSON.pretty_generate(json_data))
          end

         render json: { filename: filename }
        elsif type == "member_share"
          member_share  = MemberShare.find(params[:id])
          filename      = "member-share-#{Time.now.to_i}.json"

          data  = ::Print::BuildMemberShare.new(
                    member_share: member_share
                  ).execute!

          json_data = {
            type: type,
            data: data
          }

          File.open("#{Rails.root}/tmp/#{filename}", "w") do |f|
            f.write(JSON.pretty_generate(json_data))
          end

          # Update printing information
          member_share.update!(
            data: {
              printed: true,
              date_printed: Date.today
            }
          )

         render json: { filename: filename }
        else
          raise "Invalid type #{type}"
        end
      end
    end
  end
end
