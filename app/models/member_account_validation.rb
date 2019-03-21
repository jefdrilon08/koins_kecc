class MemberAccountValidation < ApplicationRecord
	STATUSES = ["pending", "for-approval", "approved", "reversed", "for-validation", "cancelled"]

	belongs_to :branch

	has_many :member_account_validation_records, dependent: :destroy
	has_many :member_account_validation_cancellations, dependent: :destroy
 	accepts_nested_attributes_for :member_account_validation_records

	validates :branch, presence: true
	validates :date_prepared, presence: true
	validates :prepared_by, presence: true
	# validates :or_number, presence: true
	validates :status, presence: true, inclusion: { in: STATUSES }
	validates :total_rf, presence: true, numericality: true
	validates :total_50_percent_lif, presence: true, numericality: true
	validates :total_advance_lif, presence: true, numericality: true
	validates :total_advance_rf, presence: true, numericality: true
	validates :total_interest, presence: true, numericality: true
	validates :total, presence: true, numericality: true
	validates :total_equity_interest, presence: true, numericality: true

	before_validation :load_defaults

  	def validated?
    	self.validated_by.present? && self.date_validated.present?
  	end

  	def for_approval?
    	self.status == "for-approval"
  	end

  	def for_validation?
    	self.status == "for-validation"
  	end

	def pending?
		self.status == "pending"
	end

	def cancelled?
		self.status == "cancelled"
	end

	def approved?
		self.status == "approved"
	end

	def reversed?
		self.status == "reversed"
	end

	def load_defaults
		if self.new_record?
		  self.status = "pending"
		end

		compute_values if self.pending? || self.cancelled? 
	end

	def compute_values
	    self.total_rf = 0.00
	    self.total_50_percent_lif = 0.00
	    self.total_equity_interest = 0.00
	    self.total_advance_lif = 0.00
	    self.total_advance_rf = 0.00
	    self.total_interest = 0.00
	    self.total = 0.00
	    self.member_account_validation_records.each do |member_account_validation_record|
	        if !member_account_validation_record.rf.nil? && !member_account_validation_record.lif_50_percent.nil? && !member_account_validation_record.equity_interest.nil? && !member_account_validation_record.advance_lif.nil? && !member_account_validation_record.advance_rf.nil? && !member_account_validation_record.interest.nil? && !member_account_validation_record.total.nil? 
	            self.total_rf += member_account_validation_record.rf
	            self.total_50_percent_lif += member_account_validation_record.lif_50_percent
	            self.total_equity_interest += member_account_validation_record.equity_interest
	            self.total_advance_lif += member_account_validation_record.advance_lif
	            self.total_advance_rf += member_account_validation_record.advance_rf
	            self.total_interest += member_account_validation_record.interest
	            self.total += member_account_validation_record.total
	        end  
	    end
  	end
end
