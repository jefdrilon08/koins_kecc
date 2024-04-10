module Api
  module V1
    class TransferMemberRecordsController < ActionController::Base
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
        @transfer_member_records = TransferMemberRecord.find(params[:id])
        @from_branch = Branch.find(@transfer_member_records[:branch_id])
        @to_branch = Branch.find(@transfer_member_records[:branch_id_to_transfer])
        
        #branch-center to  other branch-center
        if params[:center_from_id].present? and params[:center_id].present? and params[:member_id] == ""
         
          from_center = params[:center_from_id]
          to_center = params[:center_id]

          config = {
            from_center: from_center,
            to_center: to_center,
            from_branch: @from_branch.id,
            to_branch: @to_branch.id,
            transfer_member_record: @transfer_member_records.id

          }

          errors = ::TransferMemberRecords::ValidateCenter.new(config: config).execute!

          if errors[:full_messages].any?
            render json: errors,status: 400
          else
            ::TransferMemberRecords::CenterTransfer.new(config: config).execute!
            render json: {message: "ok"}
          end

          
        
        #member to other branch-center
        elsif params[:member_id] and params[:center_id] and params[:center_from_id] == ""
          
          center = Center.find(params[:center_id])
          member = Member.find(params[:member_id])
          active_loans= Loan.where(member_id: member.id,status: "active")
          member_accounts = MemberAccount.where("member_id = ? and balance > ? and account_subtype != ?",member.id, 0.0,"Credit Life Insurance Plan")
            config={
              member: member,
              center: center,
              active_loans: active_loans,
              member_accounts: member_accounts,
              transfer_member_records: @transfer_member_records
              
            }

          errors = ::TransferMemberRecords::ValidateAddMember.new(config: config).execute!
          if errors[:full_messages].any?
              render json: errors, status: 400
              raise errors.inspect
          else
              ::TransferMemberRecords::AddMember.new(config: config).execute!
              render json:  { message: "ok" }
          end

        elsif params[:center_id].present? and params[:center_from_id].present? and params[:member_id].present? 
          
          @errors = {
            messages: [],
            full_messages: []
          }

          @errors[:messages] << {
            key: "cannot be",
            message: "#{@branch.name} Member and #{@branch.name} Center has value"
          }

          @errors[:messages].each do |e|
            @errors[:full_messages] << e[:message]
          end

          if @errors[:full_messages].any?
              render json: @errors, status: 400
          end

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
