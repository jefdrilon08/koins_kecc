module Api
  module V1
    class ClaimsController < ApplicationController
      def create
        member = Member.find(params[:member_id])
        claim_type = params[:claim_type]
        branch = member.branch 
        center = member.center 

        claim = Claim.new(
                  member: member,
                  branch: branch,
                  center: center,
                  claim_type: claim_type,
                  data: {}
                )

        if claim.save
          render json: { id: claim.id } 
        else
          render errors: claim.errors
        end
      end

      def save
        claim         = Claim.find(params[:id])
        date_prepared = params[:date_prepared]
        prepared_by   = params[:prepared_by]
        data          = params[:data]
    
        errors = []
        if claim.claim_type == "BLIP"
          errors = ::Claims::ValidateBlip.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "CLIP"
          errors = ::Claims::ValidateClip.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "HIIP"
          errors = ::Claims::ValidateHiip.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "K-KALINGA"
          errors = ::Claims::ValidateKalinga.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "CALAMITY ASSISTANCE"
          errors = ::Claims::ValidateCalamity.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "K-BENTE"
          errors = ::Claims::ValidateKbente.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "KUYA JUN SCHOLARSHIP PROGRAM"
          errors = ::Claims::ValidateScholarship.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!      
        end

        if errors.size > 0 
          render json: { errors: errors }, status: 402
        else
          claim.update!(data: data, date_prepared: date_prepared, prepared_by: prepared_by)
          render json: {message: "ok"}                            
        end
      end


      def approved
        claim = Claim.find(params[:id])

        if claim.pending? 
          claim.update!(status: "approved")
        end
      end
    end
  end
end
