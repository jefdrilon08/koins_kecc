class MembershipPaymentRecordsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    membership_payment_record = MembershipPaymentRecord.find(params[:id])
    member                    = membership_payment_record.member

    membership_payment_record.destroy!

    redirect_to member_path(member)
  end
end
