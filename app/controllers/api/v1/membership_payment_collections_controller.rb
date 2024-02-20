module Api
  module V1
    class MembershipPaymentCollectionsController < ActionController::Base
      before_action :authenticate_user!

      def fetch
        membership_payment_collection = MembershipPaymentCollection.find(params[:id])

        render json: membership_payment_collection
      end

      def remove_member
        config  = {
          membership_payment_collection:  MembershipPaymentCollection.where(id: params[:id]).first,
          member: Member.where(id: params[:member_id]).first,
          user: current_user
        }

        errors  = ::MembershipPaymentCollections::ValidateRemoveMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::MembershipPaymentCollections::RemoveMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def add_member
        config  = {
          membership_payment_collection:  MembershipPaymentCollection.where(id: params[:id]).first,
          member: Member.where(id: params[:member_id]).first,
          user: current_user
        }

        errors  = ::MembershipPaymentCollections::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::MembershipPaymentCollections::AddMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def fetch_members
        membership_payment_collection = MembershipPaymentCollection.find(params[:id])

        members = Member.active.where(
                    center_id: membership_payment_collection.center_id
                  ).where.not(
                    id: membership_payment_collection.member_ids
                  ).order("last_name ASC").map{ |o|
                    {
                      id: o.id,
                      name: o.full_name,
                      center: {
                        id: o.center.id,
                        name: o.center.name
                      }
                    }
                  }

        render json: { members: members }
      end

      def update_particular
        membership_payment_collection = MembershipPaymentCollection.find(params[:id])
        data                          = membership_payment_collection.try(:data).try(:with_indifferent_access)
        particular                    = params[:particular]

        if membership_payment_collection.pending?
          data[:accounting_entry][:particular]  = particular

          membership_payment_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_or_number
        membership_payment_collection   = MembershipPaymentCollection.find(params[:id])
        data      = membership_payment_collection.try(:data).try(:with_indifferent_access)
        or_number = params[:or_number]

        if membership_payment_collection.pending?
          data[:or_number]                            = or_number
          data[:accounting_entry][:data][:or_number]  = or_number

          membership_payment_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_ar_number
        membership_payment_collection   = MembershipPaymentCollection.find(params[:id])
        data      = membership_payment_collection.try(:data).try(:with_indifferent_access)
        ar_number = params[:ar_number]

        if membership_payment_collection.pending?
          data[:ar_number]                            = ar_number
          data[:accounting_entry][:data][:ar_number]  = ar_number

          membership_payment_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def approve
        membership_payment_collection = MembershipPaymentCollection.where(id: params[:id]).first

        config  = {
          membership_payment_collection: membership_payment_collection,
          user: current_user
        }

        errors  = ::MembershipPaymentCollections::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          membership_payment_collection.update!(status: "processing")

          ProcessApproveMembershipPaymentCollection.perform_later({
            id: membership_payment_collection.id,
            user_id: current_user.id
          })

          render json: { message: "ok" }
        end
      end

      def modify_transaction_record
        membership_payment_collection = MembershipPaymentCollection.where(id: params[:id]).first

        current_transaction = params[:current_transaction]
        current_member      = params[:current_member]

        config  = {
          membership_payment_collection: membership_payment_collection,
          current_transaction: current_transaction,
          current_member: current_member,
          user: current_user
        }

        errors  = ::MembershipPaymentCollections::ValidateModifyTransactionRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: { errors: errors }, status: 400
        else
          membership_payment_collection = ::MembershipPaymentCollections::ModifyTransactionRecord.new(
                                            config: config
                                          ).execute!

          render json: membership_payment_collection
        end
      end

      def create
        collection_date = params[:collection_date].try(:to_date)
        branch_id       = params[:branch_id]
        center_id       = params[:center_id]

        config  = {
          collection_date: collection_date,
          branch_id: branch_id,
          center_id: center_id,
          user: current_user
        }

        errors  = ::MembershipPaymentCollections::ValidateCreateMembershipPaymentCollection.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          membership_payment_collection = ::MembershipPaymentCollections::CreateMembershipPaymentCollection.new(
                                            config: config
                                          ).execute!

          render json: { id: membership_payment_collection.id }
        end
      end
    end
  end
end
