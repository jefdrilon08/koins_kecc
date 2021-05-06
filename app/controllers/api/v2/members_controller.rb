module Api
  module V2
    class MembersController < ApiController
      before_action :authenticate_api_member!

      def upload_file
        file_name = params[:file_name]
        file      = params[:file]

        AttachmentFile.create!(
          member: @member,
          file_name: file_name,
          file: file
        )

        render json: { message: "ok" }
      end

      def update_password
        password              = params[:password]
        password_confirmation = params[:password_confirmation]

        if password.present? and password_confirmation.present? and password == password_confirmation
          @member.update!(
            password: password,
            password_confirmation: password_confirmation
          )

          render json: { message: "ok" }
        else
          render json: { errors: ["invalid password"] }, status: 403
        end
      end

      def loan_products
        loan_products = ReadOnlyLoanProduct.select("*")
                          .order(
                            "priority ASC, name ASC"
                          ).map{ |o|
                            {
                              id: o.id,
                              name: o.name
                            }
                          }

        render json: { loan_products: loan_products }
      end

      def co_makers
        members = ReadOnlyMember.active.where(
                    center_id: @member.center_id
                  ).where.not(
                    id: @member.id
                  ).order(
                    "last_name ASC"
                  ).map{ |o|
                    {
                      id: o.id,
                      first_name: o.first_name,
                      middle_name: o.middle_name,
                      last_name: o.last_name,
                      full_name: o.full_name
                    }
                  }

        render json: { members: members }
      end
    end
  end
end
