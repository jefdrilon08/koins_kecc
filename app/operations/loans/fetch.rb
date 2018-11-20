module Loans
  class Fetch
    def initialize(config:)
      @config = config
      @member = @config[:member]
      @loan   = @config[:loan]

      if @loan.blank?
        @loan = Loan.new(
                  id: "",
                  branch_id: @member.branch.id,
                  center_id: @member.center.id,
                  date_prepared: Date.today,
                  member_id: @member.id,
                  principal: 5000.00,
                  loan_product_id: "",
                  term: "weekly",
                  pn_number: "",
                  payment_type: "cash",
                  num_installments: 25,
                  project_type_id: "",
                  status: "pending",
                  data: {
                    clip_number: "",
                    voucher: {
                      check_number: "",
                      payee: "",
                      date_requested: Date.today
                    },
                    co_makers: [],
                    co_maker_two: "",
                    co_maker_one: {
                      id: "",
                      first_name: "",
                      middle_name: "",
                      last_name: ""
                    }
                  }
                )
      end
    end

    def execute!
      @data = {
        id: @loan.id,
        branch_id: @loan.branch_id,
        center_id: @loan.center_id,
        date_prepared: @loan.date_prepared,
        member_id: @loan.member_id,
        principal: @loan.principal.to_f.round(2),
        loan_product_id: @loan.loan_product_id,
        term: @loan.term,
        pn_number: @loan.pn_number,
        payment_type: @loan.payment_type,
        num_installments: @loan.num_installments,
        project_type_id: @loan.project_type_id,
        status: @loan.status,
        data: @loan.data
      }

      @data
    end
  end
end
