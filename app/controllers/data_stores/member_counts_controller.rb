module DataStores
  class MemberCountsController < DataStoreController
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
  end
end
