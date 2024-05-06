module Administration
  class MemberSharesController < ApplicationController
    before_action :authenticate_user!
    def index
      branch_ids = @branches.pluck(:id)
      
    
      @member_shares = MemberShare
        .not_printed
        .includes(member: :branch)
        .where(members: { branch_id: branch_ids })

       
      @members = Member
        .active
        .left_outer_joins(:member_shares)
        .includes(:branch)
        .where(branch_id: branch_ids, member_shares: { id: nil })
        .order(last_name: :asc)

      if params[:branch_id].present?
        @branch_id  = params[:branch_id]
        @branch     = Branch.find(@branch_id)

        @member_shares  = @member_shares.where("members.branch_id = ?", @branch.id)
        @members        = @members.where(branch_id: @branch.id)
      end

      @members       = @members.page(params[:page]).per(LIST_PAGE_SIZE)
      @member_shares = @member_shares.page(params[:page]).per(LIST_PAGE_SIZE)

      @subheader_items = [
        { text: "Administration" },
        { text: "Member Shares Monitoring" }
      ]
    end

    def print
      
      # @member_shares  = MemberShare.printed.joins(:member).where("members.branch_id IN (?)", @branches.pluck(:id)).order(Arel.sql("member_shares.data->> 'date_printed' DESC"))

      @member_shares = MemberShare
        .printed
        .includes(member: [:branch, :center])
        .where(members: { branch_id: @branches.pluck(:id) })
        .order(Arel.sql("member_shares.data->>'date_printed' DESC"))

      if params[:branch_id].present?
        @branch_id  = params[:branch_id]
        #raise @branch_id.inspect
        @member_shares  = @member_shares.where("members.branch_id =  ?" , @branch_id) 
      end
      if params[:center_id].present?
        @member_shares  = @member_shares.where("members.center_id =  ?" , params[:center_id]) 
      end
      if params[:start_date].present? and params[:end_date].present?
        #d = (params[:end_date].to_date + 1).to_s
        @member_shares = @member_shares.where("member_shares.data->> 'date_printed' >= ? and member_shares.data->> 'date_printed' <= ?  ", params[:start_date] , params[:end_date])
      end

      @subheader_side_actions = []
         @subheader_side_actions << {
          id: "btn-print-sc",
          link: "#",
          class: "fa fa-print",
          text: "Print",
        }

    end

    def no_certificates
      @data = {}
      @data[:sfp] = []

      x = Member.joins(:member_accounts).where(
            "members.status = 'active' and member_accounts.account_type = 'EQUITY' and member_accounts.account_subtype = 'Share Capital' and members.branch_id IN (?)", @branches.pluck(:id)).order(
            "member_accounts.updated_at ASC"
          )

      x.each do |y|
       sfp = {}
       total_share = MemberAccount.where(member_id: y.id , account_type: 'EQUITY' , account_subtype: 'Share Capital').sum(:balance)
       eq_date = MemberAccount.where(member_id: y.id , account_type: 'EQUITY' , account_subtype: 'Share Capital').pluck(:updated_at).to_s
 
       mem_cert = Member.joins(:member_shares).where("members.id = ? and member_shares.is_void IS NULL" , y.id).sum(:number_of_shares)
       total_share_count = (total_share/100).to_i
       if total_share_count > mem_cert
        sfp[:id] = y.id
        sfp[:branch] = Branch.find(y.branch_id).name
        sfp[:full_name] = y.full_name
        sfp_center = y.center_id 
        sfp[:center] = Center.find(sfp_center).name
        sfp[:shares_printed] = mem_cert
        sfp[:shares_for_printing] = total_share_count - mem_cert
        sfp[:eq_date] = eq_date.to_date
        @data[:sfp] << sfp 
       end
      end

      @subheader_items = [
        { text: "Administration" },
        { text: "Member Shares Monitoring" },
        { text: "No Certificates" }
      ]
    end

    def no_certificatesx
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
     
      
      @member_shares = MemberShare
        .not_printed
        .includes(member: :branch)
        .where(members: { branch_id: @branches.pluck(:id) })
        .order(date_of_issue: :desc)
        .page(params[:page])
        .per(LIST_PAGE_SIZE)

        @branch_id = params[:branch_id] 

        if params[:start_date].present?
          @member_shares = @member_shares.where("date_of_issue = ?" , params[:start_date])
        end
    
        if @branch_id.present?  
            @member_shares = @member_shares.where("members.branch_id = ?", @branch_id)
        end

        
      @subheader_items = [
        { text: "Administration" },
        { text: "Member Shares Monitoring" },
        { text: "Not Printed" }
      ]
     
    end

    def printed

      if params[:branch_id].present? or params[:center_id].present? or (params[:start_date].present? and params[:end_date].present?)
        @member_shares = MemberShare
          .printed
          .includes(member: [:branch, :center])
          .where(members: { branch_id: @branches.pluck(:id) })
          .order(Arel.sql("member_shares.data->>'date_printed' DESC"))

        if params[:branch_id].present?
          @branch_id  = params[:branch_id]
          #raise @branch_id.inspect
          @member_shares  = @member_shares.where("members.branch_id =  ?" , @branch_id) 
        end
        if params[:center_id].present?
          @member_shares  = @member_shares.where("members.center_id =  ?" , params[:center_id]) 
        end
        if params[:start_date].present? and params[:end_date].present?
          #d = (params[:end_date].to_date + 1).to_s
          @member_shares = @member_shares.where("member_shares.data->> 'date_printed' >= ? and member_shares.data->> 'date_printed' <= ?  ", params[:start_date] , params[:end_date])
        end

        @member_shares = @member_shares.page(params[:page]).per(LIST_PAGE_SIZE)
      
      else
        @member_shares = nil

      end

      @subheader_items = [
        { text: "Administration" },
        { text: "Member Shares Monitoring" },
        { text: "Printed" }
      ]
    end
  end
end
