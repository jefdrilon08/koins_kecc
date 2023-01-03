module BankTransfers
  class CreateChannel
    def initialize(config:)
      @config        = config
      @transfer_name = @config[:transfer_name]
      @code          = @config[:code]  

    @tranfer_option = TransferOption.create(
      name:@transfer_name,
      code:@code
      )
    end

    
    def execute!
      @tranfer_option.save!
    end

  end


end 