module Icpr
  class GenerateIcpr
    attr_accessor :data, :result

    def initialize(config:)
      @config = config
      @year   = @config[:year]
      @branch = @config[:branch]

      @data = {
        year: @year,
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        equity_interest_rate: 0.00,
        savings_rate: 0.00,
        cbu_rate: 0.00,
        status: "pending",
        total_ave_equity: 0.00,
        total_equity_interest_amount: 0.00,
        total_savings_distribute: 0.00,
        total_cbu_distribute: 0.00,
        records: []
      }
    end

    def execute!
      query!

      @data[:records] = @result.map{ |o|
                          temp  = {
                            id: o.fetch("member_id"),
                            first_name: o.fetch("first_name"),
                            middle_name: o.fetch("middle_name"),
                            last_name: o.fetch("last_name"),
                            identification_number: o.fetch("identification_number"),
                            status: o.fetch("member_status"),
                            member_account_id: o.fetch("member_account_id"),
                            savings_account_id: o.fetch("savings_account_id"),
                            savings_account_balance: o.fetch("savings_account_balance"),
                            cbu_account_id: o.fetch("cbu_account_id"),
                            cbu_account_balance: o.fetch("cbu_account_balance"),
                            center: {
                              id: o.fetch("center_id"),
                              name: o.fetch("center_name")
                            },
                            branch: {
                              id: @branch.id,
                              name: @branch.name
                            },
                            latest_transaction_date: o.fetch("latest_transaction_date").try(:to_date),
                            latest_ending_balance: o.fetch("ending_balance").try(:to_f).try(:round, 2),
                            previous_transaction_date: o.fetch("previous_transaction_date").try(:to_date),
                            previous_ending_balance: o.fetch("previous_ending_balance").try(:to_f).try(:round, 2),
                            months: [],
                            total_equity: 0.00,
                            ave_equity: 0.00,
                            equity_interest_amount: 0.00,
                            savings_distribute: 0.00,
                            cbu_distribute: 0.00
                          }

                          latest_transaction_month    = temp[:latest_transaction_date].try(:month)
                          previous_transaction_month  = temp[:previous_transaction_date].try(:month)

                          (1..12).to_a.each do |m|
                            d = {
                              month_index: m,
                              month: Date::MONTHNAMES[m],
                              year: @year,
                              amount: 0.00
                            }
                        #raise "jef".inspect
                            if previous_transaction_month.present? and temp[:previous_ending_balance].present? and temp[:previous_ending_balance] > 0.00
                              if temp[:latest_ending_balance].present? and temp[:latest_ending_balance] > 0.00 and m >= latest_transaction_month
                                d[:amount] = temp[:latest_ending_balance] 
                              elsif temp[:latest_ending_balance].present? and temp[:latest_ending_balance] == 0.00
                                if m < latest_transaction_month
                                  d[:amount] = temp[:previous_ending_balance]
                                else
                                  d[:amount] = temp[:latest_ending_balance]
                                end
                              else
                                d[:amount] = temp[:previous_ending_balance]
                              end
                            elsif temp[:previous_ending_balance].present? and temp[:latest_ending_balance].present?
                              if m >= latest_transaction_month
                                d[:amount] = temp[:latest_ending_balance]
                              end
                            elsif temp[:previous_ending_balance].present? and temp[:latest_ending_balance].present?  and temp[:latest_ending_balance] > 0.00
                              if m >= latest_transaction_month
                                d[:amount] = temp[:latest_ending_balance]
                              end
                            elsif temp[:previous_ending_balance].nil? and temp[:latest_ending_balance].present?  and temp[:latest_ending_balance] > 0.00
                              if m >= latest_transaction_month
                                d[:amount] = temp[:latest_ending_balance]
                              end
                            end

                            temp[:months] << d
                          end

                          temp[:total_equity] = temp[:months].inject(0){ |sum, hash| sum + hash[:amount] }.to_f.round(2)
                          temp[:ave_equity]   = (temp[:total_equity] / 12).round(2)


                          temp
                        }

      @data
    end

    def query!
      #members.branch_id = '#{@branch.id}'
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT DISTINCT ON(members.identification_number, member_accounts.id)
                    members.id AS member_id,
                    members.first_name,
                    members.middle_name,
                    members.last_name,
                    members.status AS member_status,
                    members.identification_number,
                    member_accounts.id AS member_account_id,
                    member_accounts.account_type,
                    member_accounts.account_subtype,
                    savings_accounts.id AS savings_account_id,
                    savings_accounts.balance AS savings_account_balance,
                    cbu_accounts.id AS cbu_account_id,
                    cbu_accounts.balance AS cbu_account_balance,
                    centers.id AS center_id,
                    centers.name AS center_name,
                    t1.transacted_at AS latest_transaction_date,
                    t1.data->>'ending_balance' AS ending_balance,
                    t2.transacted_at AS previous_transaction_date,
                    t2.data->>'ending_balance' AS previous_ending_balance
                  FROM
                    member_accounts
                  INNER JOIN members ON
<<<<<<< HEAD
                   member_accounts.member_id = members.id AND member_accounts.account_type = 'EQUITY' AND member_accounts.account_subtype = 'Share Capital' AND members.status IN ('active', 'resigned') AND members.branch_id = '#{@branch.id}'
=======
                    member_accounts.member_id = members.id AND member_accounts.account_type = 'EQUITY' AND member_accounts.account_subtype = 'Share Capital' AND members.status IN ('active', 'resigned') AND members.branch_id = '#{@branch.id}' and member_accounts.member_id = 'd0198de0-a516-403e-b35b-1ff268de68c1'
>>>>>>> f364c09ed0aeca2fa3e4ffb18a4ebfe18d8ed165
                  INNER JOIN member_accounts AS savings_accounts ON
                    savings_accounts.member_id = members.id AND savings_accounts.account_type = 'SAVINGS' AND savings_accounts.account_subtype = 'K-IMPOK'
                  INNER JOIN member_accounts AS cbu_accounts ON
                    cbu_accounts.member_id = members.id AND cbu_accounts.account_type = 'EQUITY' AND cbu_accounts.account_subtype = 'CBU'
                  INNER JOIN centers ON
                    centers.id = member_accounts.center_id and centers.id = '0ac3c815-194b-4a1e-982d-a370beaa8e74'
                  LEFT JOIN account_transactions AS t1 ON
                    t1.subsidiary_id = member_accounts.id AND t1.status = 'approved' AND EXTRACT(year FROM t1.transacted_at) = '#{@year}'::int
                  LEFT JOIN account_transactions AS t2 ON
                    t2.subsidiary_id = member_accounts.id AND t2.status = 'approved' AND EXTRACT(year FROM t2.transacted_at) < '#{@year}'::int
                  ORDER BY
                    members.identification_number, member_accounts.id, members.last_name ASC, t1.transacted_at DESC, t1.updated_at DESC, t2.transacted_at DESC, t2.transacted_at DESC
                EOS
    end
  end
end
