module Adjustments
  module Moratoriums
    class Create
      def initialize(config:)
        @config = config

        @branch           = @config[:branch]
        @center           = @config[:center]
        @member           = @config[:member]
        @date_initialized = @config[:date_initialized]
        @number_of_days   = @config[:number_of_days].try(:to_i)
        @user             = @config[:user]
        
        @active_loans = Loan.active.where(member_id: @member.id)

        @member_moratorium  = MemberMoratorium.new(
                                branch: @branch,
                                center: @center,
                                member: @member,
                                date_initialized: @date_initialized,
                                number_of_days: @number_of_days,
                                data: {
                                  active_loans: [],
                                  branch: {
                                    id: @branch.id,
                                    name: @branch.name
                                  },
                                  center: {
                                    id: @center.id,
                                    name: @center.name
                                  },
                                  member: {
                                    id: @member.id,
                                    first_name: @member.first_name,
                                    last_name: @member.last_name,
                                    middle_name: @member.middle_name,
                                    full_name: @member.full_name,
                                    identification_number: @member.identification_number
                                  }
                                }
                              )
      end

      def execute!
        build_active_loans!

        @member_moratorium.save!

        @member_moratorium
      end

      def build_active_loans!
        @active_loans.each do |loan|
          loan_product = loan.loan_product

          @member_moratorium.member_loan_moratoria.build({
                                      loan: loan,
                                      branch: @branch,
                                      center: @center,
                                      member: @member,
                                      date_initialized: @date_initialized,
                                      number_of_days: @number_of_days,
                                      data: {
                                        pn_number: loan.pn_number,
                                        loan_product: {
                                          id: loan_product.id,
                                          name: loan_product.name
                                        },
                                        branch: {
                                          id: @branch.id,
                                          name: @branch.name
                                        },
                                        center: {
                                          id: @center.id,
                                          name: @center.name
                                        },
                                        member: {
                                          id: @member.id,
                                          first_name: @member.first_name,
                                          last_name: @member.last_name,
                                          middle_name: @member.middle_name,
                                          full_name: @member.full_name,
                                          identification_number: @member.identification_number
                                        }
                                      }
                                    })

          @member_moratorium.data["active_loans"] << {
            id: loan.id,
            pn_number: loan.pn_number,
            loan_product: {
              id: loan_product.id,
              name: loan_product.id
            }
          }
        end
      end
    end
  end
end
