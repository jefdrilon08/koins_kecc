module Members
  class SaveMakePayment
    def initialize(config:)
      
      @config = config
      @make_payment = MakePayment.new
      @make_payment_type = "MAKE PAYMENT"
      @member_id  =  @config[:member_id]
      @book       = @config[:book]
      @particular = @config[:particular]
      @or_number  = @config[:or_number]
      @si_number  = @config[:si_number]
      @ar_number  = @config[:ar_number]
      @user       = @config[:user]
      @branch = Branch.find(Member.find(@member_id).branch_id)
      @make_payment_type = @config[:make_payment_type]
      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!

      
      config = {
                member_id: @member_id,
                make_payment_type: @make_payment_type
              }
    
      
      @data = ::Members::BuildMakePayments.new(config: config).execute!
    
      
    end
    def execute!
      @meta = {
        book: @book,
        particular: @particular,
        or_number: @or_number,
        si_number: @si_number,
        ar_number: @ar_number,
      }
      
      @make_payment.member_id = @member_id
      @make_payment.created_by = @user.full_name
      @make_payment.transaction_date = @date_approved
      @make_payment.make_payment_type = @make_payment_type
      @make_payment.meta = @meta
      @make_payment.status = "pending"
      @make_payment.data = @data[:records]

      @make_payment.save! 
      @make_payment 
    end
  end
end
