module Insurance
  class FetchInforced
    def initialize(config:)
      @config             = config
      @branch             = @config[:branch]
      @as_of              = @config[:as_of].try(:to_date)
      @insurance_subtype  = @config[:insurance_subtype]
      @default_amount     = @config[:default_amount].to_f.round(2)

      @data = {
        as_of: @as_of,
        insurance_type: @insurance_type,
        default_amount: @default_amount,
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        records: []
      }
    end

    def execute!
      query!

      @data[:records] = @result.select{ |o|
                          begin
                            insured_amount  = (((@as_of - o.fetch("recognition_date").to_date).to_i / 7).to_i + 1) * @default_amount
                            ending_balance  = o.fetch("ending_balance").to_f.round(2)

                            o[:insured_amount]  = insured_amount

                            ending_balance >= insured_amount
                          rescue ArgumentError
                            raise "Recognition date: #{o.fetch("recognition_date").inspect} Status: #{o.fetch("member_status")} Insurance Status: #{o.fetch("insurance_status")}"
                          end
                        }

      @data
    end

    private

    def query!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT DISTINCT ON(members.identification_number, member_accounts.id)
                    members.id AS member_id,
                    members.first_name,
                    members.middle_name,
                    members.last_name,
                    members.status AS member_status,
                    members.insurance_status AS insurance_status,
                    members.data->'recognition_date' AS recognition_date,
                    members.member_type,
                    members.gender,
                    members.date_resigned AS date_resigned,
                    members.identification_number,
                    member_accounts.id AS member_account_id,
                    member_accounts.account_type,
                    member_accounts.account_subtype,
                    centers.id AS center_id,
                    centers.name AS center_name,
                    t1.transacted_at AS latest_transaction_date,
                    t1.amount AS latest_transaction_amount,
                    t1.data->>'ending_balance' AS ending_balance
                  FROM
                    member_accounts
                  INNER JOIN members ON
                    member_accounts.member_id = members.id AND member_accounts.account_type = 'INSURANCE' AND member_accounts.account_subtype = '#{@insurance_subtype}' AND members.branch_id = '#{@branch.id}' AND members.data->>'recognition_date' IS NOT NULL AND members.insurance_status <> 'pending' AND members.status <> 'archived' AND DATE(members.data->>'recognition_date') < DATE('#{@as_of}')
                  INNER JOIN centers ON
                    centers.id = member_accounts.center_id
                  LEFT JOIN account_transactions AS t1 ON
                    t1.subsidiary_id = member_accounts.id AND t1.status = 'approved' AND DATE(t1.transacted_at) < DATE('#{@as_of}')
                  ORDER BY
                    members.identification_number, member_accounts.id, members.last_name ASC, t1.transacted_at DESC, t1.updated_at DESC
                EOS
    end
  end
end
