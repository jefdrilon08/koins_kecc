module Accounting
  module TrialBalances
    class ValidateCreate < AppValidator
      attr_accessor :errors, :start_date, :end_date, :branch, :accounting_fund, :user

      def initialize(start_date:, end_date:, branch:, accounting_fund:, user:)
        super()

        @start_date       = start_date
        @end_date         = end_date
        @branch           = branch
        @accounting_fund  = accounting_fund
        @user             = user
      end

      def execute!
        if @start_date.blank?
          @errors[:messages] << {
            key: "start_date",
            message: "start_date required"
          }
        end

        if @end_date.blank?
          @errors[:messages] << {
            key: "end_date",
            message: "end_date required"
          }
        end

        if @start_date.present? and @end_date.present? and @start_date > @end_date
          @errors[:messages] << {
            key: "trial_balance",
            message: "invalid start and end dates"
          }
        end

        if @start_date and @end_date.present? and @branch.present?
          # Check existing trial balance
          existing_tb = DataStore.select("id,meta,status,as_of,start_date,end_date,created_at,updated_at").trial_balances.where(
                          "meta->>'branch_id' = ? AND start_date = ? AND end_date = ? AND meta->>'accounting_fund_id' = ?",
                          branch.id,
                          start_date,
                          end_date,
                          accounting_fund.try(:id)
                        ).first

          if existing_tb.present?
            @errors[:messages] << {
              key: "trial_balance",
              message: "Existing trial balance detected (ID: #{existing_tb.id}). Please delete first. Branch ID: #{branch.id} Start Date: #{start_date} End Date: #{end_date}."
            }
          end

          # Check against closing records
          latest_closing_record = DataStore.year_end_closings.where(
                                    "status = ? AND meta->>'branch_id' = ?",
                                    "closed",
                                    branch.id
                                  ).order(
                                    "created_at ASC"
                                  ).last

          if latest_closing_record.present?
            date_closed = latest_closing_record.meta["closing_date"].to_date

            if start_date < date_closed and end_date > date_closed
              @errors[:messages] << {
                key: "trial_balance",
                message: "Closing date #{date_closed} is in between start and end dates"
              }
            end
          end

          # Check according to accounting entry closing record
          if accounting_fund.present?
            latest_closing_entry = AccountingEntry.year_end_closing.where("date_posted <= ?", end_date).where(accounting_fund_id: accounting_fund.try(:id), branch_id: branch.id).order("date_posted DESC").first
          else
            latest_closing_entry = AccountingEntry.year_end_closing.where("date_posted <= ? AND branch_id = ?", end_date, branch.id).order("date_posted DESC").first
          end

          if latest_closing_entry.present?
            date_closed = latest_closing_entry.date_posted

            if start_date < date_closed and end_date > date_closed
              @errors[:messages] << {
                key: "trial_balance",
                message: "Closing date #{date_closed} is in between start and end dates"
              }
            end
          end
        end

        if @branch.blank?
          @errors[:messages] << {
            key: "branch",
            message: "branch required"
          }
        end

        if @user.blank?
          @errors[:messages] << {
            key: "user",
            message: "User required"
          }
        end

        #not_yet_implemented!
      
        @errors[:messages].each do |m|
          @errors[:full_messages] << m[:message]
        end

        @errors
      end
    end
  end
end
