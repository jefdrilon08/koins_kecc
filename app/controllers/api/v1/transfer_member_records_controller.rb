module Api
  module V1
    class TransferMemberRecordsController < ApplicationController
      before_action :authenticate_user!

      def create
        branch_id = params[:branch_id]
        branch_id_to_transfer = params[:branch_id_to_transfer]

        config = {
          branch_id: branch_id,
          branch_id_to_transfer: branch_id_to_transfer,
          user: current_user
        }
        errors = ::TransferMemberRecords::ValidateTransferMemberRecords.new(config: config).execute!

          if errors[:full_messages].any?
            render json: errors, status: 400
          else
            transfer_member_records= ::TransferMemberRecords::SaveTransferMemberRecords.new(config: config).execute!
             render json: {id: transfer_member_records.id}
          end

      end
      def add_member
        center = Center.find(params[:center_id])
        member =Member.find(params[:member_id])
        active_loans= Loan.where(member_id: member.id,status: "active")
        member_accounts = MemberAccount.where("member_id = ? and balance > ? and account_subtype != ?",member.id, 0.0,"Credit Life Insurance Plan")
        transfer_member_records = TransferMemberRecord.find(params[:id])

        config={
          member: member,
          center: center,
          active_loans: active_loans,
          member_accounts: member_accounts,
          transfer_member_records: transfer_member_records
          
        }

        errors = ::TransferMemberRecords::ValidateAddMember.new(config: config).execute!
        if errors[:full_messages].any?
            render json: errors, status: 400
        else
            ::TransferMemberRecords::AddMember.new(config: config).execute!
            render json:  { message: "ok" }
        end

      end

      def approve
        transfer_member_records = TransferMemberRecord.find(params[:id])
        config = {
          transfer_member_records: transfer_member_records,
          user: current_user.id
        }
        

        errors = ::TransferMemberRecords::ValidateApprove.new(config: config).execute!
          if errors[:messages].any?
              render json: errors, status: 400
          else
              
            transfer_member_records.update(status: "processing")
            args = {
              transfer_member_records: transfer_member_records.id,
              user: current_user.id
            }

            ProcessApproveTransferMemberRecords.perform_later(args)
            render json: { message: "ok" }
          end
      end

      def add_particular
        transfer_member_record = TransferMemberRecord.find(params[:id])
        particular_to = params[:particular_to]
        particular_from = params[:particlar_from]

        config = {
          transfer_member_record: transfer_member_record,
          particular_to: particular_to,
          particular_from: particular_from
        } 

        ::TransferMemberRecords::SaveParticular.new(config: config).execute!
        render json: {message: "ok"}
        
      end

      def delete_member
        transfer_member_records = params[:id]
        member_id = params[:member_id]

        config = {
          transfer_member_records: transfer_member_records,
          member_id: member_id
        }

        errors = ::TransferMemberRecords::ValidateDeleteMember.new(config: config).execute!

        if errors[:messages].any?
            render json: errors, status: 400
        else
            ::TransferMemberRecords::DeleteMember.new(config: config).execute!
            render json: { message: "ok" }
        end

      end

    end
  end
end
