module Branches
  class FetchMemberCounts
    def initialize(config:)
      @config = config

      @branch   = @config[:branch]
      @as_of    = @config[:as_of].try(:to_date) || Date.today
      @cluster  = @branch.cluster
      @area     = @cluster.area

      @default_savings_key  = Settings.default_savings_key
      @member_types         = Settings.default_member_types

      @data = {
        member_type_counts: [],
        counts: {
          pure_savers: {
            male: 0,
            female: 0,
            others: 0,
            total: 0,
            members: []
          },
          loaners: {
            male: 0,
            female: 0,
            others: 0,
            total: 0,
            members: []
          },
          active_members: {
            inforce: 0,
            lapsed: 0,
            pending: 0,
            male: 0,
            female: 0,
            others: 0,
            total: 0,
            female_inforce: 0,
            male_inforce: 0,
            female_pending: 0,
            male_pending: 0,
            female_lapsed: 0,
            male_lapsed: 0,
            members: []
          }
        },
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
      }
    end

    def execute!
      query!
      compute_pure_savers!
      compute_loaners!
      compute_active_members!
      compute_member_types!

      @data
    end

    def compute_member_types!
      @member_types.each do |m|
        m_data  = {
          member_type: m,
          members: [],
          count: 0
        }

        @data[:counts][:active_members][:members].select{ |o|
          o[:member_type] == m
        }.each do |o|
          m_data[:members] << o
        end

        @data[:counts][:pure_savers][:members].select{ |o|
          o[:member_type] == m
        }.each do |o|
          m_data[:members] << o
        end

        @data[:counts][:loaners][:members].select{ |o|
          o[:member_type] == m
        }.each do |o|
          m_data[:members] << o
        end

        m_data[:count]  = m_data[:members].size

        @data[:member_type_counts] << m_data
      end
    end

    def compute_active_members!
      @data[:counts][:active_members][:members] = @result.select{ |o|
                                                    o.fetch("count").to_i == 0 && ((o.fetch("amount").try(:to_f).try(:round, 2) || 0.00) == 0.00)
                                                  }.map{ |o|
                                                    {
                                                      id: o.fetch("id"),
                                                      identification_number: o.fetch("identification_number"),
                                                      first_name: o.fetch("first_name"),
                                                      middle_name: o.fetch("middle_name"),
                                                      last_name: o.fetch("last_name"),
                                                      member_type: o.fetch("member_type"),
                                                      gender: o.fetch("gender"),
                                                      insurance_status: o.fetch("insurance_status"),
                                                      total_balance: o.fetch("amount").try(:to_f).try(:round, 2) || 0.00,
                                                      branch: {
                                                        id: @branch.id,
                                                        name: @branch.name
                                                      },
                                                      center: {
                                                        id: o.fetch("center_id"),
                                                        name: o.fetch("center_name")
                                                      },
                                                      officer: {
                                                        id: o.fetch("officer_id"),
                                                        first_name: o.fetch("officer_first_name"),
                                                        last_name: o.fetch("officer_last_name")
                                                      }
                                                    }
                                                  }
      
      @data[:counts][:active_members][:male]    = @data[:counts][:active_members][:members].select{ |o| o[:gender] == "Male" }.size
      @data[:counts][:active_members][:female]  = @data[:counts][:active_members][:members].select{ |o| o[:gender] == "Female" }.size
      @data[:counts][:active_members][:others]  = @data[:counts][:active_members][:members].select{ |o| o[:gender] == "Others" }.size
      @data[:counts][:active_members][:inforce] = @data[:counts][:active_members][:members].select{ |o| o[:insurance_status] == "inforce" }.size
      @data[:counts][:active_members][:male_inforce] = @data[:counts][:active_members][:members].select{ |o| o[:insurance_status] == "inforce" and o[:gender] == "Male" }.size
      @data[:counts][:active_members][:female_inforce] = @data[:counts][:active_members][:members].select{ |o| o[:insurance_status] == "inforce" and o[:gender] == "Female" }.size
      @data[:counts][:active_members][:male_pending] = @data[:counts][:active_members][:members].select{ |o| o[:insurance_status] == "pending" and o[:gender] == "Male" }.size
      @data[:counts][:active_members][:female_pending] = @data[:counts][:active_members][:members].select{ |o| o[:insurance_status] == "pending" and o[:gender] == "Female" }.size
      @data[:counts][:active_members][:male_lapsed] = @data[:counts][:active_members][:members].select{ |o| o[:insurance_status] == "lapsed" and o[:gender] == "Male" }.size
      @data[:counts][:active_members][:female_lapsed] = @data[:counts][:active_members][:members].select{ |o| o[:insurance_status] == "lapsed" and o[:gender] == "Female" }.size
      @data[:counts][:active_members][:lapsed]  = @data[:counts][:active_members][:members].select{ |o| o[:insurance_status] == "lapsed" }.size
      @data[:counts][:active_members][:pending] = @data[:counts][:active_members][:members].select{ |o| o[:insurance_status] == "pending" }.size
      @data[:counts][:active_members][:total]   = @data[:counts][:active_members][:members].size
    end

    def compute_loaners!
      @data[:counts][:loaners][:members]  = @result.select{ |o|
                                              o.fetch("count").to_i > 0
                                            }.map{ |o|
                                              {
                                                id: o.fetch("id"),
                                                identification_number: o.fetch("identification_number"),
                                                first_name: o.fetch("first_name"),
                                                middle_name: o.fetch("middle_name"),
                                                last_name: o.fetch("last_name"),
                                                member_type: o.fetch("member_type"),
                                                gender: o.fetch("gender"),
                                                total_balance: o.fetch("amount").try(:to_f).try(:round, 2) || 0.00,
                                                branch: {
                                                  id: @branch.id,
                                                  name: @branch.name
                                                },
                                                center: {
                                                  id: o.fetch("center_id"),
                                                  name: o.fetch("center_name")
                                                },
                                                officer: {
                                                  id: o.fetch("officer_id"),
                                                  first_name: o.fetch("officer_first_name"),
                                                  last_name: o.fetch("officer_last_name")
                                                }
                                              }
                                            }
      
      @data[:counts][:loaners][:male]   = @data[:counts][:loaners][:members].select{ |o| o[:gender] == "Male" }.size
      @data[:counts][:loaners][:female] = @data[:counts][:loaners][:members].select{ |o| o[:gender] == "Female" }.size
      @data[:counts][:loaners][:others] = @data[:counts][:loaners][:members].select{ |o| o[:gender] == "Others" }.size
      @data[:counts][:loaners][:total]  = @data[:counts][:loaners][:members].size
    end

    def compute_pure_savers!
      @data[:counts][:pure_savers][:members]  = @result.select{ |o|
                                                  o.fetch("count").to_i == 0 && o.fetch("amount").to_f.round(2) > 0
                                                }.map{ |o|
                                                  {
                                                    id: o.fetch("id"),
                                                    identification_number: o.fetch("identification_number"),
                                                    first_name: o.fetch("first_name"),
                                                    middle_name: o.fetch("middle_name"),
                                                    last_name: o.fetch("last_name"),
                                                    member_type: o.fetch("member_type"),
                                                    gender: o.fetch("gender"),
                                                    total_balance: o.fetch("amount").try(:to_f).try(:round, 2) || 0.00,
                                                    branch: {
                                                      id: @branch.id,
                                                      name: @branch.name
                                                    },
                                                    center: {
                                                      id: o.fetch("center_id"),
                                                      name: o.fetch("center_name")
                                                    },
                                                    officer: {
                                                      id: o.fetch("officer_id"),
                                                      first_name: o.fetch("officer_first_name"),
                                                      last_name: o.fetch("officer_last_name")
                                                    }
                                                  }
                                                }
      
      @data[:counts][:pure_savers][:male]   = @data[:counts][:pure_savers][:members].select{ |o| o[:gender] == "Male" }.size
      @data[:counts][:pure_savers][:female] = @data[:counts][:pure_savers][:members].select{ |o| o[:gender] == "Female" }.size
      @data[:counts][:pure_savers][:others] = @data[:counts][:pure_savers][:members].select{ |o| o[:gender] == "Others" }.size
      @data[:counts][:pure_savers][:total]  = @data[:counts][:pure_savers][:members].size
    end

    def query!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT
                    members.id,
                    members.identification_number,
                    members.first_name,
                    members.middle_name,
                    members.last_name,
                    members.date_resigned,
                    members.status,
                    members.insurance_status,
                    members.insurance_date_resigned,
                    members.gender,
                    members.member_type,
                    centers.id AS center_id,
                    centers.name AS center_name,
                    users.id AS officer_id,
                    users.identification_number AS officer_identification_number,
                    users.first_name AS officer_first_name,
                    users.last_name AS officer_last_name,
                    COUNT(loans.*),
                    COALESCE(SUM(tt.ending_balance::float), 0.00) AS amount
                  FROM members 
                  LEFT JOIN
                  (
                    SELECT DISTINCT ON(member_accounts.id)
                      member_accounts.member_id,
                      member_accounts.id AS member_account_id,
                      member_accounts.account_subtype AS member_account_subtype,
                      account_transactions.id AS account_transaction_id,
                      account_transactions.transacted_at AS latest_transaction_date,
                      account_transactions.data->>'ending_balance' AS ending_balance
                    FROM 
                      member_accounts
                    INNER JOIN
                      account_transactions ON member_accounts.id = account_transactions.subsidiary_id AND member_accounts.account_type = 'SAVINGS'
                    ORDER BY
                      member_accounts.id, account_transactions.transacted_at DESC
                  ) tt ON tt.member_id = members.id
                  LEFT JOIN
                    loans ON 
                    (
                      loans.member_id = members.id
                      AND
                      loans.status = 'active' AND loans.date_approved <= '#{@as_of}' AND loans.max_active_date >= '#{@as_of}' AND loans.branch_id = '#{@branch.id}'
                    )
                    OR
                    (
                      loans.member_id = members.id
                      AND
                      loans.status = 'paid' AND loans.date_approved <= '#{@as_of}' AND loans.max_active_date > '#{@as_of}' AND loans.branch_id = '#{@branch.id}'
                    )
                  LEFT JOIN
                    centers ON centers.id = members.center_id
                  LEFT JOIN
                    users ON users.id = centers.user_id
                  WHERE 
                    (members.status = 'active' AND members.branch_id::text = '#{@branch.id}')
                    OR 
                    (members.status = 'resigned' AND members.date_resigned > '#{@as_of}' AND members.branch_id::text = '#{@branch.id}')
                  GROUP BY
                    members.id, centers.id, users.id
                EOS
    end
  end
end
