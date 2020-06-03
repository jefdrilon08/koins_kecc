module Api
  module V1
    class EquityWithdrawalCollectionsController < ApplicationController
      before_action :authenticate_user!

      def fetch
        equity_withdrawal_collection = EquityWithdrawalCollection.find(params[:id])

        render json: equity_withdrawal_collection
      end

      def remove_member
        config  = {
          equity_withdrawal_collection: EquityWithdrawalCollection.where(id: params[:id]).first,
          member:             Member.where(id: params[:member_id]).first,
          user:               current_user
        }

        errors  = ::EquityWithdrawalCollections::ValidateRemoveMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::EquityWithdrawalCollections::RemoveMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def add_member
        config  = {
          equity_withdrawal_collection:  EquityWithdrawalCollection.where(id: params[:id]).first,
          member: Member.where(id: params[:member_id]).first,
          user: current_user
        }

        errors  = ::EquityWithdrawalCollections::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::EquityWithdrawalCollections::AddMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def fetch_members
        equity_withdrawal_collection = EquityWithdrawalCollection.find(params[:id])

        members = Member.active_and_resigned.where(
                    branch_id: equity_withdrawal_collection.branch_id
                  ).where.not(
                    id: equity_withdrawal_collection.member_ids
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
        equity_withdrawal_collection    = EquityWithdrawalCollection.find(params[:id])
        data                            = equity_withdrawal_collection.try(:data).try(:with_indifferent_access)
        particular                      = params[:particular]

        if equity_withdrawal_collection.pending?
          data[:particular]  = particular

          equity_withdrawal_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def approve
        equity_withdrawal_collection = EquityWithdrawalCollection.where(id: params[:id]).first

        config  = {
          equity_withdrawal_collection: equity_withdrawal_collection,
          user: current_user
        }

        errors  = ::EquityWithdrawalCollections::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::EquityWithdrawalCollections::Approve.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def modify_transaction_record
        equity_withdrawal_collection = EquityWithdrawalCollection.where(id: params[:id]).first

        current_transaction = params[:current_transaction]
        current_member      = params[:current_member]

        config  = {
          equity_withdrawal_collection: equity_withdrawal_collection,
          current_transaction: current_transaction,
          current_member: current_member,
          user: current_user
        }

        errors  = ::EquityWithdrawalCollections::ValidateModifyTransactionRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: { errors: errors }, status: 400
        else
          equity_withdrawal_collection = ::EquityWithdrawalCollections::ModifyTransactionRecord.new(
                                            config: config
                                          ).execute!

          render json: equity_withdrawal_collection
        end
      end

      def create
        collection_date = params[:collection_date].try(:to_date)
        branch_id       = params[:branch_id]

        config  = {
          collection_date: collection_date,
          branch_id: branch_id,
          user: current_user
        }

        errors  = ::EquityWithdrawalCollections::ValidateCreateEquityWithdrawalCollection.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          equity_withdrawal_collection = ::EquityWithdrawalCollections::CreateEquityWithdrawalCollection.new(
                                    config: config
                                  ).execute!

          render json: { id: equity_withdrawal_collection.id }
        end
      end
    end
  end
end
