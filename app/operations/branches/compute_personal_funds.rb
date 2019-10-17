module Branches
  class ComputePersonalFunds
    def initialize(config:)
      @config = config

      @branch   = @config[:branch]
      @as_of    = @config[:as_of].try(:to_date) || Date.today
      @cluster  = @branch.cluster
      @area     = @cluster.area

      @members  = Member.where(branch_id: @branch.id).order("last_name ASC")

      @default_member_accounts  = Settings.default_member_accounts

      # For progress update
      @data_store_id  = @config[:data_store_id]
      if @data_store_id.present?
        @data_store = DataStore.find(@data_store_id)
      end

      if @default_member_accounts.blank?
        raise "Settings not found: default_member_accounts"
      end

      @data = {
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        cluster: {
          id: @cluster.id,
          name: @cluster.name
        },
        area: {
          id: @area.id,
          name: @area.name
        },
        as_of: @as_of,
        member_records: [],
        records: [],
        total: 0.00
      }
    end

    def execute!
      size      = @members.size

#      @members.each_with_index do |o, i|
#        @data[:records] <<  ::Members::ComputePersonalFunds.new(
#                              config: {
#                                member: o,
#                                as_of: @as_of
#                              }
#                            ).execute!    
#      end

      member_accounts = MemberAccount.joins(
                          "INNER JOIN account_transactions ON member_accounts.id = account_transactions.subsidiary_id"
                        ).where(
                          "account_transactions.transacted_at <= ? AND member_accounts.member_id IN (?)", 
                          @as_of,
                          @members.pluck(:id)
                        ).select(
                          "DISTINCT ON(member_accounts.id, account_transactions.transacted_at, member_accounts.member_id) member_accounts.id, member_accounts.member_id, member_accounts.account_type, member_accounts.account_subtype, DATE(transacted_at), account_transactions.data"
                        ).order(
                          "account_transactions.transacted_at ASC"
                        )

      branches  = Branch.where(id: @members.pluck(:branch_id))
      centers   = Center.where(id: @members.pluck(:center_id)).map{ |o|
                    officer = o.user

                    {
                      id: o.id,
                      name: o.name,
                      officer: {
                        id: officer.id,
                        first_name: officer.first_name,
                        last_name: officer.last_name,
                        identification_number: officer.identification_number
                      }
                    }
                  }

      @members.each_with_index do |o, i|
        center  = centers.select{ |c|
                    c[:id] == o.center_id
                  }.first

        branch  = branches.select{ |b|
                    b.id == o.branch_id
                  }.first

        officer = center[:officer]

        temp_data = {
          member: {
            id: o.id,
            first_name: o.first_name,
            middle_name: o.middle_name,
            last_name: o.last_name,
            identification_number: o.identification_number,
            status: o.status
          },
          as_of: @as_of,
          branch: branch,
          center: center,
          officer: officer,
          total: 0.00,
          accounts: []
        }

        member_accounts_for_member  = member_accounts.select{ |member_account|
                                        member_account.member_id == o.id
                                      }

        @default_member_accounts.each do |s|
          account = {
            account_type: s.account_type,
            account_subtype: s.account_subtype,
            member_id: o.id,
            balance: 0.00,
            account_transaction_id: 0.00
          }

          m_account = member_accounts_for_member.select{ |temp_m_ac|
                        temp_m_ac[:account_type] == s.account_type && temp_m_ac[:account_subtype] == s.account_subtype
                      }.first

          if m_account.present?
            account[:balance] = m_account[:data]["ending_balance"].to_f.round(2)
          end

          temp_data[:accounts] << account
        end

        temp_data[:accounts].each do |x|
          temp_data[:total] += x[:balance]
        end

        temp_data[:total] = temp_data[:total].to_f.round(2)

        @data[:records] << temp_data
      end

      @data[:officers]  = @data[:records].map{ |mr| mr[:officer] }.uniq
      @data[:centers]  = @data[:records].map{ |mr| mr[:center] }.uniq

#      @data[:officers]  = @data[:member_records].map{ |mr| mr[:officer] }.uniq.map{ |officer|
#                            {
#                              officer:  officer,
#                              centers:  @data[:member_records].select{ |temp|
#                                          temp[:officer][:id] == officer[:id]
#                                        }.pluck(:center).uniq.map{ |center|
#                                          {
#                                            center:   center,
#                                            records:  @data[:member_records].select{ |mr|
#                                                        mr[:center][:id] == center[:id]
#                                                      }
#                                          }
#                                        }
#                            }
#                          }
      @data
    end
  end
end
