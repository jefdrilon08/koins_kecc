module InsuranceWithdrawalCollections  
  class LoadInsuranceWithdrawalFromCsvFile
    def initialize(config:)
      @config       = config
      @file         = @config[:file]
      @prepared_by  = @config[:prepared_by]
      @branch       = @config[:branch]
      @paid_at      = @config[:paid_at]

      @default_withdrawal_accounts = Settings.default_withdrawal_accounts

      @insurance_withdrawal_collection  = ::InsuranceWithdrawalCollections::CreateInsuranceWithdrawalCollection.new(
                                          config: {
                                                collection_date: @paid_at,
                                                user: @prepared_by,
                                                branch_id: @branch.id
                                              }
                                        ).execute!

      @data = @insurance_withdrawal_collection.data.with_indifferent_access
    end

    def execute!    
      load_csv_file!
      @insurance_withdrawal_collection
    end

    private

    def recompute_totals!
      @insurance_withdrawal_collection = InsuranceWithdrawalCollection.find(@insurance_withdrawal_collection.id)

        r_config = {
          current_member: {
            id: @member.id
          },
          data: @insurance_withdrawal_collection.data.with_indifferent_access,
          user: @prepared_by,
          insurance_withdrawal_collection: @insurance_withdrawal_collection
        }

        data  = ::InsuranceWithdrawalCollections::RecomputeTotals.new(
                  config: r_config
                ).execute!

        @insurance_withdrawal_collection.update!(data: data)

        @insurance_withdrawal_collection
    end

    def load_csv_file!
      CSV.foreach(@file.path, headers: true) do |row|
        @member = Member.where(identification_number: row['identification_number']).first
      
        @member_object  = {
          id: @member.id,
          full_name: @member.full_name,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name,
          identification_number: @member.identification_number
        }

        # Build member records
        @records  = []
        @default_withdrawal_accounts.each_with_index do |o, i|
          member_account  = MemberAccount.where(member_id: @member.id, account_subtype: o.account_subtype, account_type: o.account_type).first
          enabled         = false

          if member_account
            enabled = true
          end

          if o[:account_subtype] == 'Life Insurance Fund'
            amount = row['LIF']
          elsif o[:account_subtype] == 'Retirement Fund'
            amount = row['RF']
          else
            amount = 0.00
          end

          record_type = o.account_type

          @records << {
            amount: amount,
            enabled: enabled,
            member_id: @member.id,
            record_type: o.account_type,
            account_subtype: o.account_subtype,
            member_account_id: member_account.try(:id)
          }
        end

        @data[:records] << {
          member: @member_object,
          records: @records,
          total_collected: 0.00
        }

        @insurance_withdrawal_collection.update!(
          data: @data
        )

        recompute_totals!
      end
      @insurance_withdrawal_collection.save!
    end
  end
end  