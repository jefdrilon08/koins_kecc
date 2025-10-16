
module Loans
  class ValidateCoMakers
    def initialize(payload:)
      @payload = (payload || {}).with_indifferent_access
      @errors  = []
    end

    def call
      product = LoanProduct.find_by(id: @payload[:loan_product_id])
      product_name = (product&.name || "").downcase

      # co_makers is an array of hashes like: [{ id: "...", name: "..." }, ...]
      co_makers   = Array.wrap(@payload.dig(:data, :co_makers)).compact
      borrower_id = @payload[:member_id] || @payload.dig(:data, :borrower_id)

      # --- RULE 1: max number allowed by product type ---
      max = max_allowed(product_name)
      if co_makers.size > max
        if max.zero?
          @errors << "This loan does not require co-makers."
        else
          @errors << "This loan allows a maximum of #{max} co-maker(s)."
        end
      end

      # --- RULE 2: borrower cannot be a co-maker ---
      ids = co_makers.map { |cm| cm[:id].to_s }
      if borrower_id.present? && ids.include?(borrower_id.to_s)
        @errors << "Borrower cannot be selected as a co-maker."
      end

      # --- RULE 3: co-makers must be unique ---
      if ids.uniq.size != ids.size
        @errors << "Co-makers must be unique."
      end

      # --- RULE 4: Unified Mega Loan special check (PB >= 3) ---
      if product_name.strip == "unified mega loan"
        co_makers.each do |cm|
          cm_id = cm[:id]
          next unless cm_id.present?

          if principal_borrowers_active_count_for_unified_mega(cm_id) >= 3
            @errors << "Member #{cm[:name]} already has 3 active Unified Mega Loan(s) as Principal Borrower."
          end
        end
      end

      @errors
    end

    private

    # Real Estate / Vehicle => 0 co-makers
    # Unified Mega Loan     => 3 co-makers
    # Default               => 2 co-makers
    def max_allowed(product_name)
      return 0 if product_name.include?("real estate") || product_name.include?("vehicle")
      return 3 if product_name.strip == "unified mega loan"
      2
    end

    # Count active Unified Mega Loans where this member is the borrower (principal)
    def principal_borrowers_active_count_for_unified_mega(member_id)
      Loan.active
          .where(member_id: member_id)
          .joins(:loan_product)
          .where("loan_products.name ILIKE ?", "Unified Mega Loan")
          .count
    end
  end
end
