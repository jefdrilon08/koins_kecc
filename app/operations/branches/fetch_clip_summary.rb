module Branches
  class FetchClipSummary
    def initialize(config:)
      @config = config
      @branch   = @config[:branch]
      @as_of    = @config[:as_of].try(:to_date) || Date.today

      @start_date = @as_of.beginning_of_month - 1.month
      @end_date = @as_of.end_of_month - 1.month

      @data = {
        records: []
      }

    end

    def execute!
      queryAllBranch
      number_clip_summary
      @data
    end

    def number_clip_summary

      @data[:records] = @result.map{ |r|
                        branch_name                   = r.fetch("branch_name")
                        identification_number         = r.fetch("identification_number")
                        name_of_member                = r.fetch('name_of_member')
                        clip_number                   = r.fetch('clip_number')
                        pn_number                     = r.fetch('pn_number')
                        date_released                 = r.fetch('date_released')
                        maturity_date                 = r.fetch('maturity_date')
                        loan_term                     = r.fetch('loan_term')
                        premium                       = r.fetch('premium')
                        amount                        = r.fetch('amount')
                        loan_product                  = r.fetch('loan_product')
                        loan_status                   = r.fetch('loan_status')
                        gender                        = r.fetch('gender')
                        date_of_birth                 = r.fetch('date_of_birth')


                        {
                          branch_name: branch_name,
                          identification_number: identification_number,
                          name_of_member: name_of_member,
                          clip_number: clip_number,
                          pn_number: pn_number,
                          date_released: date_released,
                          maturity_date: maturity_date,
                          loan_term: loan_term,
                          premium: premium,
                          amount: amount,
                          loan_product: loan_product,
                          loan_status: loan_status,
                          gender: gender,
                          date_of_birth: date_of_birth
                        }
                      }
    end

    def queryAllBranch
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
        SELECT
        d.name AS branch_name,
        c.identification_number AS identification_number,
        CONCAT(c.last_name,', ',c.first_name,', ', c.middle_name) AS name_of_member,
        a.data ->>'clip_number' AS clip_number,
        a.pn_number AS pn_number,
        a.date_released AS date_released,
        a.maturity_date AS maturity_date,
        a.num_installments as loan_term,
        case when a.num_installments = 15
          then ROUND(((a.principal * 0.014) * a.num_installments / 60),2)
        when a.num_installments = 35
          then ROUND(((a.principal * 0.014) * a.num_installments / 46.666666667),2)
        else
          ROUND(((a.principal * 0.014) * a.num_installments / 50),2)
        end as premium,
        a.principal as amount,
        b.name as loan_product,
        case when a.maturity_date <= '#{@end_date}'
          then 'Matured'
        else a.status
        END as loan_status,
        c.gender as gender,
        c.date_of_birth as date_of_birth

        FROM loans a
          LEFT JOIN loan_products b ON a.loan_product_id = b.id
          LEFT JOIN members c ON a.member_id = c.id
              left join branches d ON a.branch_id = d.id
        WHERE a.date_released between '#{@start_date}' and '#{@end_date}'
                and a.data ->>'clip_number' NOT IN ('','0')
        ORDER by d.name asc
      EOS
    end
  end
end
