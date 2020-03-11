class MonitoringController < ApplicationController
  before_action :load_defaults

  def accounting_entry_subsidiary_balancing
    @branches = @branches.map{ |o| { id: o.id, name: o.name } }
  end

  def accounting_entry_precision
    @branches = @branches.map{ |o| { id: o.id, name: o.name } }
  end

  def no_membership_payments
    @members  = Member.active

    if @branches.present?
      @members  = @members.where(branch_id: @branches.pluck(:id))
    end

    @members  = @members.where.not(id: MembershipPaymentRecord.all.pluck(:member_id).uniq)

    @members  = @members.order("last_name ASC").page(@page).per(LIST_PAGE_SIZE)

    @data = ::Monitoring::FetchMembersWithNoMembershipPaymentRecords.new(
              config: {
                branches: @branches,
                members: @members
              }
            ).execute!
  end
end
