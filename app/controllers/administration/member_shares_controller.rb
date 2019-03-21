module Administration
  class MemberSharesController < ApplicationController
    before_action :authenticate_user!

    def index
      @member_shares  = MemberShare.not_printed.joins(:member).where("members.branch_id IN (?)", @branches.pluck(:id))
      @members        = Member.active.where.not(id: MemberShare.all.pluck(:member_id).uniq).where(branch_id: @branches.pluck(:id)).order("last_name ASC")

      if params[:branch_id].present?
        @branch_id  = params[:branch_id]
        @branch     = Branch.find(@branch_id)

        @member_shares  = @member_shares.where("members.branch_id = ?", @branch.id)
        @members        = @members.where(branch_id: @branch.id)
      end

      #@member_shares  = @member_shares.page(params[:page]).per(20)
    end

    def no_certificates
      @members        = Member.active.where.not(id: MemberShare.all.pluck(:member_id).uniq).where(branch_id: @branches.pluck(:id)).order("last_name ASC")

      @member_accounts  = MemberAccount.where(
                            member_id: @members.pluck(:id),
                            account_type: "EQUITY",
                            account_subtype: "Share Capital"
                          )

      @member_records = @members.map{ |m|
                          member_account  = MemberAccount.where(
                                              member_id: m.id,
                                              account_type: "EQUITY",
                                              account_subtype: "Share Capital"
                                            ).first

                          latest_transaction  = AccountTransaction.personal_funds.where(
                                                  "subsidiary_id = ? AND amount > 0",
                                                  member_account.id
                                                ).order("transacted_at ASC").last

                          date_of_issue = latest_transaction.transacted_at.to_date

                          {
                            id: m.id,
                            first_name: m.first_name,
                            middle_name: m.middle_name,
                            last_name: m.last_name,
                            full_name: m.full_name,
                            date_of_issue: date_of_issue,
                            branch: {
                              id: m.branch.id,
                              name: m.branch.name
                            },
                            center: {
                              id: m.center.id,
                              name: m.center.name
                            }
                          }
                        }

      @member_records = @member_records.sort_by{ |k, v|
                          k[:date_of_issue].to_date
                        }
    end

    def not_printed
      @member_shares  = MemberShare.not_printed.joins(:member).where("members.branch_id IN (?)", @branches.pluck(:id)).order("date_of_issue DESC")
      @member_shares  = @member_shares.page(params[:page]).per(20)
    end

    def printed
      @member_shares  = MemberShare.printed.joins(:member).where("members.branch_id IN (?)", @branches.pluck(:id)).order("date_of_issue DESC")
      @member_shares  = @member_shares.page(params[:page]).per(20)
    end
  end
end
