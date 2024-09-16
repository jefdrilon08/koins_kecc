module Members
  class MemberSharesController < ApplicationController
    before_action :authenticate_user!
    before_action :load_member!
      
    def new
      date_of_issue = @member.membership_payment_records.paid.order("date_paid ASC").last.try(:date_paid)
      settings  = nil
      actv_share = MemberShare.where("member_id = ? and is_void IS NULL" , @member.id).sum(:number_of_shares)
      share_bal = MemberAccount.where(member_id: @member.id , account_type: 'EQUITY' , account_subtype: "Share Capital").sum(:balance)
      add_share = (share_bal / 100).to_i
      number_of_shares = add_share - actv_share
      @no_of_share = number_of_shares
      Settings.default_member_accounts.each do |s|
        if s.account_type == "EQUITY" and s.account_subtype == "Share Capital"
          settings  = s

          member_account  = MemberAccount.where(
                              member_id: @member.id,
                              account_type: s.account_type,
                              account_subtype: s.account_subtype
                            ).first

          if member_account.present?
            latest_transaction  = AccountTransaction.personal_funds.where(
                                    "subsidiary_id = ? AND amount > 0",
                                    member_account.id
                                  ).order("transacted_at ASC").last

            date_of_issue = latest_transaction.transacted_at.to_date
          end
        end
      end

      @member_share = MemberShare.new(date_of_issue: date_of_issue , number_of_shares: number_of_shares)

      @subheader_items = [
        { text: "Members", is_link: true, path: members_path },
        { text: "#{@member.full_name}", is_link: true, path: member_path(@member) },
        { text: "New" }
      ]

      @subheader_side_actions = []

      @payload = {
        id: @member_share.id,
        recognitionDate: @member.recognition_date,
        identificationNumber: @member.identification_number
      }
    end

    def create
      @member_share         = MemberShare.new(member_share_params)
      @member_share.member  = @member

      @member_share.data  = {
        printed: false,
        date_printed: Date.today
      }

      if @member_share.save

        ActivityLog.create!(
          content: "#{current_user.full_name} created member_share #{@member_share.certificate_number} of #{@member.full_name}",
          activity_type: "create",
          data: {
            user_id: current_user.id,
            member_share: @member_share
          }
        )

        redirect_to member_member_share_path(@member, @member_share)
      else
        @subheader_items = [
          { text: "Members", is_link: true, path: members_path },
          { text: "#{@member.full_name}", is_link: true, path: member_path(@member) },
          { text: "New" }
        ]

        render :new
      end
    end

    def edit
      @member_share = MemberShare.find(params[:id])

      @subheader_items = [
        { text: "Members", is_link: true, path: members_path },
        { text: "#{@member.full_name}", is_link: true, path: member_path(@member) },
        { text: "#{@member_share}", is_link: true, path: member_member_share_path(@member, @member_share) },
        { text: "Edit" }
      ]

      @subheader_side_actions = []

      @payload = {
        id: @member_share.id
      }
    end

    def flag_as_printed
      @member_share = MemberShare.find(params[:member_share_id])
      @member_share.update!(data: { printed: true, date_printed: Date.today})

      redirect_to member_member_share_path(@member_share.member.id, @member_share.id)
    end

    def update
      @member_share         = MemberShare.find(params[:id])
      @member_share.member  = @member

      if @member_share.update(member_share_params)
        data  = @member_share.data.with_indifferent_access

        data[:printed] = false

        @member_share.update!(data: data)

        ActivityLog.create!(
          content: "#{current_user.full_name} updated member_share #{@member_share.certificate_number} of #{@member.full_name}",
          activity_type: "modification",
          data: {
            user_id: current_user.id,
            member_share: @member_share
          }
        )

        redirect_to member_member_share_path(@member, @member_share)
      else
        @subheader_items = [
          { text: "Members", is_link: true, path: members_path },
          { text: "#{@member.full_name}", is_link: true, path: member_path(@member) },
          { text: "#{@member_share}", is_link: true, path: member_member_share_path(@member, @member_share) },
          { text: "Edit" }
        ]

        render :edit
      end
    end
    def show
      @member_share = MemberShare.find(params[:id])

      @subheader_items = [
        { text: "Members", is_link: true, path: members_path },
        { text: "#{@member.full_name}", is_link: true, path: member_path(@member) },
        { text: "Member Share" }
      ]

      @subheader_side_actions = []

      if @member_share.data["is_printed"].to_s == "false"
        @subheader_side_actions << {
          text: "Flag as Printed", link: member_member_share_flag_as_printed_path(@member, @member_share), class: "fa fa-check"
        }
      end

      @subheader_side_actions << { text: "Edit", class: "fa fa-pencil-alt", link: edit_member_member_share_path(@member, @member_share) }
      @subheader_side_actions << { text: "Print", id: "btn-print", class: "fa fa-print", data: { id: @member_share.id } }
      @subheader_side_actions << { text: "Void", class: "fa fa-times", link: member_member_share_path(@member, @member_share), data: { method: :delete, confirm: "Are you sure?" } }
    
      @payload = {
        id: @member_share.id,
        forMba: @member_share.for_kmba?,
        forCoop: @member_share.for_kcoop?
      }
    end
    def destroy
      @member_share       = MemberShare.find(params[:id])
      certificate_number  = @member_share.certificate_number

      if @member_share.member.active?
        flash[:error] = "Cannot update member share to void because the associated member's status is active."
        redirect_to member_path(@member_share.member) and return
      end

      if @member_share.is_void
        @member_share.update(certificate_for: "VOID")
      else
        @member_share.update(is_void: true, certificate_for: "KCOOP")
      end

      unless @member_share.save
        Rails.logger.error "Failed to update member_share #{@member_share.id}: #{@member_share.errors.full_messages.join(', ')}"
      end
      
      #@member_share.destroy!

      ActivityLog.create!(
        content: "#{current_user.full_name} void member_share #{certificate_number} of #{@member.full_name}",
        activity_type: "delete",
        data: {
          user_id: current_user.id,
          certificate_number: certificate_number
        }
      )

      redirect_to member_path(@member_share.member)
    end

    private

    def load_member!
      @member = Member.find(params[:member_id])
    end

    def member_share_params
      params.require(:member_share).permit!
    end
  end
end
