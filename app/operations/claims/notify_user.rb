module Claims
  class NotifyUser
    include SendGrid

    def initialize(user:, claim:)
      @claim = claim
      @user = user
      @email_address = @user.email
    end

    def execute!
      ActiveRecord::Base.transaction do
        from    = Email.new(email: "kmbakoins2020@gmail.com")
        to      = Email.new(email: @email_address)
        subject = "#{@claim.status.titleize}"
        content = Content.new(
                    type: "text/html",
                    value: "Magandang araw po
                            <br />
                            Mayroon po tayong claims na #{@claim.status}. I-click ang link sa ibaba.
                            <br />
                            Link: <a href='http://139.162.47.128:8081/claims/#{@claim.id}' target='_blank'>#{@claim.member.full_name_titleize} - #{@claim.status}</a>
                            "
                  )

        mail      = Mail.new(from, subject, to, content)
        sg        = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
        response  = sg.client.mail._('send').post(request_body: mail.to_json)
      end
    end
  end
end
