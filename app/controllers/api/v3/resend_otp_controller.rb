module Api
    module V3
      class ResendOtpController < ApplicationController
  
        def resend
          # Ensure the parameters are present
          if params[:member_id].blank? || params[:mobile_number].blank?
            return render json: { success: false, message: "Missing member_id or mobile_number" }, status: :unprocessable_entity
          end
  
          member_id = params[:member_id]
          mobile_number = params[:mobile_number]
          
          # Find the member using the member_id
          user = Member.find_by(id: member_id)
  
          if user.present? && user.mobile_number == mobile_number
            # Generate OTP and update member data
            user_data = user.data.with_indifferent_access
            new_otp_code = rand(100_000..999_999).to_s  # Generate a new OTP code
            
            user_data["is_otp_code"] = new_otp_code  # Set the new OTP
            # user_data["is_otp_verified"] = false  # Reset OTP verification flag
  
            if user.update(data: user_data)
              # Send OTP via SMS (Optional: use an SMS service)
              # SmsService.send_otp(mobile_number, new_otp_code)
  
              render json: { success: true, otp: new_otp_code, message: "OTP sent successfully" }, status: :ok
            else
              render json: { success: false, message: "Failed to update OTP" }, status: :unprocessable_entity
            end
          else
            render json: { success: false, message: "User not found or mobile number mismatch" }, status: :not_found
          end
        end
  
      end
    end
  end
  