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
        records: [],
        total: 0.00
      }
    end

    def execute!
      compute_records!

      @data[:officers]  = @data[:records].map{ |mr| mr[:officer] }.uniq
      @data[:centers]  = @data[:records].map{ |mr| mr[:center] }.uniq

      @data
    end

    private

    def compute_records!
      member_accounts = MemberAccount.joins(
                          "INNER JOIN account_transactions ON member_accounts.id = account_transactions.subsidiary_id"
                        ).joins(
                          "INNER JOIN members ON member_accounts.member_id = members.id"
                        ).joins(
                          "INNER JOIN branches ON members.branch_id = branches.id"
                        ).joins(
                          "INNER JOIN centers ON members.center_id = centers.id"
                        ).joins(
                          "INNER JOIN users ON centers.user_id = users.id"
                        ).where(
                          "account_transactions.transacted_at <= ? AND member_accounts.member_id IN (?)", 
                          @as_of,
                          @members.pluck(:id)
                        ).select(
                          "DISTINCT ON(member_accounts.id, account_transactions.transacted_at, member_accounts.member_id, account_transactions.updated_at) member_accounts.id, member_accounts.member_id, member_accounts.account_type, member_accounts.account_subtype, DATE(transacted_at), account_transactions.data, branches.id AS branch_id, branches.name AS branch_name, centers.id AS center_id, centers.name AS center_name, users.id AS officer_id, users.first_name AS officer_first_name, users.last_name AS officer_last_name, users.identification_number AS officer_identification_number"
                        ).order(
                          "account_transactions.transacted_at DESC, account_transactions.updated_at DESC"
                        )

      @members.each_with_index do |o, i|
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
          branch: {
            id: "",
            name: ""
          },
          center: {
            id: "",
            name: ""
          },
          officer: {
            id: "",
            first_name: "",
            last_name: "",
            identification_number: ""
          },
          total: 0.00,
          accounts: []
        }

        member_accounts_for_member  = member_accounts.select{ |member_account|
                                        member_account.member_id == o.id
                                      }

        @default_member_accounts.each do |s|
          account = {
            id: "",
            account_type: s.account_type,
            account_subtype: s.account_subtype,
            member_id: o.id,
            balance: 0.00,
            account_transaction_id: ""
          }

          m_account = member_accounts_for_member.select{ |temp_m_ac|
                        temp_m_ac[:account_type] == s.account_type && temp_m_ac[:account_subtype] == s.account_subtype
                      }.first

          if m_account.present?
            account[:id]      = m_account[:id]
            account[:balance] = m_account[:data]["ending_balance"].to_f.round(2)

            temp_data[:center] = {
              id: m_account[:center_id],
              name: m_account[:center_name]
            }

            temp_data[:branch] = {
              id: m_account[:branch_id],
              name: m_account[:branch_name]
            }

            temp_data[:officer] = {
              id: m_account[:officer_id],
              first_name: m_account[:officer_first_name],
              last_name: m_account[:officer_last_name],
              identification_number: m_account[:identification_number]
            }
          end

          temp_data[:accounts] << account
        end

        temp_data[:accounts].each do |x|
          temp_data[:total] += x[:balance]
        end

        temp_data[:total] = temp_data[:total].to_f.round(2)

        @data[:records] << temp_data
      end
    end
  end
end
