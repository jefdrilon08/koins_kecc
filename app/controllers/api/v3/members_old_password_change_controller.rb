module Api
    module V3
      class MembersOldPasswordChangeController < ApplicationController
  
        def change_old_password
            
          member_id = params[:member_id]
          old_password = params[:old_password]
          new_password = params[:new_password]
          confirm_new_password = params[:confirm_new_password]


          if member_id.blank?
            return render json: { success: false, message: "Missing member_id" }, status: :unprocessable_entity
          end
  
         
          member = Member.find_by(id: member_id)

          if member
          encrypted_password = member.encrypted_password
          
         
          config = {
            member: member,
            old_password: old_password,
            new_password: new_password,
            confirm_new_password: confirm_new_password
          }
  
        
           cmd = ::Members::ValidateMemberChangePassword.new(config: config)

           log_output = StringIO.new
           $stdout = log_output 
 
           begin
              # Run validation
              cmd.execute!
              rescue StandardError => e
            
              return render json: { success: false, message: e.message }, status: :unprocessable_entity
              ensure
              $stdout = STDOUT # Reset stdout to original
           end
 
           # Capture the content written to log_output
           captured_output = log_output.string
             
            if member 
            render json: { success: true,
                           message: "Member found",
                           member_id: member_id, 
                           encrypted_password: encrypted_password,
                           old_password: old_password,
                           captured_output: captured_output, 
                           new_password: new_password,}, status: :ok
            else
            render json: { success: false, message: "Member not found" }, status: :not_found
            end
          end
        end
  
      end
    end
  end
  