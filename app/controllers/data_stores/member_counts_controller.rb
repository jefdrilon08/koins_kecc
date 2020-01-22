module DataStores
  class MemberCountsController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.member_counts.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'as_of' AS date) DESC" 
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.member_counts.where(id: params[:id]).first
      @data   = @record.data.with_indifferent_access

      if @record.blank? or @record.processing? or @record.error?
        redirect_to "/data_stores/member_counts"
      end

      @data_officers  = ::DataStores::BuildMemberCountsPerOfficer.new(
                          mc_data: @data
                        ).execute!
    end

    def destroy
      @record = DataStore.member_counts.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/member_counts"
    end
  end
end
