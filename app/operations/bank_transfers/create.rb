module BankTransfers
  class Create
    def initialize(config:)
      @config        = config
      @bank_name     = @config[:bank_name]
      @amount        = @config[:amount]
      @transfer      = @config[:transfer]
      @accounting    = @config[:accounting]

    @bank_transfer = BankTransfer.create(
      name:@bank_name,
      amount:@amount,
      transfer_option_id:@transfer,
      accounting_entry_id:@accounting
      )
    end

    
    def execute!
      @bank_transfer.save!
    end

  end


end 
