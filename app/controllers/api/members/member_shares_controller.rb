module Api
    module Members
      class MemberSharesController < ::Api::V3::ApplicationController
        before_action :authenticate_member!
        before_action :authorize_active_member!
        
        def index
            #puts "MEMBERzzz " + @current_member.inspect
            cmd = ::Members::GetMemberShares.new(
                member: @current_member
            )

            cmd.execute!
    
            render json: cmd.payload
        end
        
      end
    end
end