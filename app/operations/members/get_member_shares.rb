module Members
    class GetMemberShares
      attr_accessor  :payload
  
      def initialize(member:)
        @member   = member
        @member_shares = MemberShare.where(member_id: @member)

        puts "@member_shares " + @member_shares.inspect
        
  
        @payload = {
          member_shares: []
        }
      end
  
      def execute!  
        # Member Shares
        @payload[:member_shares] = @member_shares.map{ |o| o }
      end
    end
  end
  