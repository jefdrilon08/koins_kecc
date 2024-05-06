module Loans
  class Fetch
    attr_accessor :loan,
                  :data

    def initialize(config:)
      @config = config
      @member = @config[:member]
      @loan   = @config[:loan]

      if @loan.blank?
        @loan = Loan.new(
                  id: "",
                  branch_id: @member.branch_id,
                  center_id: @member.center_id,
                  date_prepared: Date.today,
                  member_id: @member.id,
                  principal: 5000.00,
                  loan_product_id: "",
                  loan_product_type_id: "",
                  loan_product_tagging_id: "",
                  term: "weekly",
                  pn_number: "",
                  payment_type: "cash",
                  num_installments: 25,
                  project_type_id: "",
                  status: "pending",
                  data: {
                    business_permit_available: false,
                    advance_insurance_available: false,
                    clip_beneficiary: {
                      first_name: "",
                      middle_name: "",
                      last_name: "",
                      date_of_birth: "",
                      relationship: ""
                    },
                    clip_number: "",
                    voucher: {
                      bank: "",
                      bank_check_number: "",
                      check_number: "",
                      payee: "",
                      date_requested: Date.today,
                      date_of_check: "",
                      bank_transaction_reference_number: "",
                      particular: build_default_loan_particular!
                    },
                    co_makers: [],
                    co_maker_three: "",
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
      # Accounting entry display
      data                  = @loan.data.with_indifferent_access
      accounting_entry_data = @loan.data.with_indifferent_access[:accounting_entry]

      branch = @loan.branch

      if @loan.active_or_paid?
        ac  = ReadOnlyAccountingEntry.where(
                branch_id: branch.id,
                reference_number: accounting_entry_data[:reference_number],
                book: accounting_entry_data[:book]
              ).first

        data[:accounting_entry] = JSON.parse(ac.to_json).with_indifferent_access

        data[:accounting_entry][:branch_id]       = branch.id
        data[:accounting_entry][:branch_name]     = branch.name
        data[:accounting_entry][:branch]          = branch.to_s.upcase
        data[:accounting_entry][:journal_entries] = ac.journal_entries.map{ |o| 
                                                      {
                                                        id: o.id,
                                                        post_type: o.post_type,
                                                        accounting_code_id: o.accounting_code.id,
                                                        accounting_code_name: "#{o.accounting_code.code} - #{o.accounting_code.name}",
                                                        amount: o.amount
                                                      }
                                                    }
      end

      @data = {
        id: @loan.id,
        branch_id: @loan.branch_id,
        center_id: @loan.center_id,
        date_prepared: @loan.date_prepared,
        member_id: @loan.member_id,
        principal: @loan.principal.to_f.round(2),
        loan_product_id: @loan.loan_product_id,
        loan_product_type_id: @loan.loan_product_type_id,
        loan_product_tagging_id: @loan.loan_product_tagging_id,
        term: @loan.term,
        pn_number: @loan.pn_number,
        payment_type: @loan.payment_type,
        num_installments: @loan.num_installments,
        project_type_id: @loan.project_type_id,
        status: @loan.status,
        data: data
      }

      if @loan.co_maker_relative_profile_picture.attached?
        @data[:co_maker_relative_profile_picture_url] = @loan.co_maker_relative_profile_picture.url 
      end

      if @loan.co_maker_non_relative_profile_picture.attached?
        @data[:co_maker_non_relative_profile_picture_url] = @loan.co_maker_non_relative_profile_picture.url
      end

      @data
    end

    def build_default_loan_particular!
      "Release of Loan - #{@member.first_name} #{@member.first_name} #{@member.last_name} cv# ________ ck# _______ clip# _______"
    end
  end
end
