module Claims
  class NotifyUser
    include SendGrid

    def initialize(user:, claim:)
      @claim = claim
      @user = user
      @email_address = @user.email

      if @claim.pending?
        @status = "For Checking"
      elsif @claim.for_approval?
        @status = "For Approval"
      elsif @claim.for_posting?
        @status = "For Posting"
      end
    end

    def execute!
      ActiveRecord::Base.transaction do
        from    = Email.new(email: "kmbakoins2020@gmail.com")
        to      = Email.new(email: @email_address)
        subject = "KMBA / CLAIMS / #{@claim.claim_type} / #{@status.upcase} / #{@claim.member.full_name} / #{@claim.branch.name.upcase}"
        content = Content.new(
                    type: "text/html",
                    value: "Claims #{@status.downcase}. Click the link below.
                            <br />
                            Link: <a href='http://139.162.47.128:8081/claims/#{@claim.id}' target='_blank'>#{@claim.member.full_name_titleize} - #{@status}</a>
                            "
                  )

        mail      = Mail.new(from, subject, to, content)
        sg        = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
        response  = sg.client.mail._('send').post(request_body: mail.to_json)
      end
    end
  end
end
