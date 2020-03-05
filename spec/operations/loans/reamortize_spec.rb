require "rails_helper"

describe Loans::Reamortize do
  describe "#execute!" do
    specify do
      config = {
        loan: create(:loan),
        p_principal: 1,
        p_monthly_interest_rate: 1,
        p_num_installments: 1,
        p_term: "monthly",
      }
      op = described_class.new(config: config)

      expected = {
        a: 1,
      }
      expect(op.execute!).to eq expected
    end
  end
end
