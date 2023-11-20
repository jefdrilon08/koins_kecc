module SmsBlast
    class Send
        def initialize(config:)
            # @billing = config[:billing_id]
            @mobile_number= config[:mobile_number]
            @content = config[:content]
            @end_point = ENV['SMS_BLAST_END_POINT']
            @app_key = ENV['SMS_BLAST_APP_KEY']
            @shortcode_mask = ENV['SMS_BLAST_SHORTCODE_MASK']
            @secret_key = ENV['SMS_BLAST_APP_SECRET']

            @config = {
                app_secret: @secret_key,
                app_key: @app_key,
                msisdn: @mobile_number,
                content: @content,
                shortcode_mask: @shortcode_mask,
                rcvd_transid: SecureRandom.uuid
            }
        end

        def execute!
            result = HTTParty.post(
                @end_point,
                body: @config.to_json,
                :headers => { 'Content-Type' => 'application/json' }
            )
            
            Rails.logger.info(puts "Sending SMS to #{@mobile_number}")
        end
    end
end

