module Claims
  class NotifyUser
    include SendGrid

    def initialize(user:, claim:)
      @claim = claim
      @users = user

      if @claim.pending?
        @status = "For Checking"
      elsif @claim.for_approval?
        @status = "For Approval"
      elsif @claim.for_posting?
        @status = "For Posting"
      end

      if @claim.declined_note.present?
        @status = "Declined"
      end

      if @claim.kalinga?
        if @claim.member.check_name == @claim.data.with_indifferent_access[:name_of_insured]
          @member = @claim.member.try(:full_name)
        else
          @member = @claim.member.try(:full_name) + " (" + (@claim.data.with_indifferent_access[:name_of_insured].try(:titleize)) + ")"
        end
      else
        @member = @claim.member.try(:full_name)
      end

      if @claim.clip?
        @claim_type = @claim.claim_type + " (" + (@claim.data.with_indifferent_access[:type_of_loan].try(:titleize)) + ")"
      else
        @claim_type = @claim.claim_type
      end
    end

    def execute!
      ActiveRecord::Base.transaction do
        from    = Email.new(email: "kmbakoins2020@gmail.com")

        @users.each do |user|
          email_address = user.email

          to      = Email.new(email: email_address)
          subject = "KMBA / Claims / #{@claim_type} / #{@status} / #{@member.try(:titleize)} / #{@claim.branch.name.try(:titleize)}"
          content = Content.new(
                      type: "text/html",
                      value: "
                              Claims #{@status.downcase}. I-click lamang ang link sa ibaba.
                              <br />
                              Link: <a href='http://139.162.47.128:8081/claims/#{@claim.id}' target='_blank'>#{@member} - #{@status}</a>
                              "
                    )

          mail      = Mail.new(from, subject, to, content)
          sg        = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
          response  = sg.client.mail._('send').post(request_body: mail.to_json)
        end
      end
    end
  end
end
