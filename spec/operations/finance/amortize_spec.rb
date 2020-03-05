require "rails_helper"

describe Finance::Amortize do
  describe "#execute!" do
    xspecify "term - weekly" do
      params = {
        principal: 123.22,
        annual_interest_rate: 123.22,
        num_installments: 2,
        term: "weekly",
      }
      op = described_class.new(params: params)

      expected = {
        emi: 320,
        interest: 516.78,
        periodic_interest: 2.3696,
        principal: 123.22,
        schedule: [
          {
            due: 320,
            index: 0,
            interest: 290.78,
            num: 1,
            principal: 29.22,
          },
          {
            due: 320,
            index: 1,
            interest: 226,
            num: 2,
            principal: 94,
          },
        ],
        total_due: 640.0,
      }
      expect(op.execute!).to eq expected
    end

    specify "interest is decreasing" do
      params = {
        principal: 8_000,
        annual_interest_rate: 0.6,
        num_installments: 25,
        term: "weekly",
      }

      result = described_class.new(params: params).execute!
      expect(result[:principal]).to eq 8_000
      expect(result[:interest]).to eq 1_260
      expect(result[:total_due]).to eq 9_260
      expect(result[:periodic_interest]).to eq 0.0115
      expect(result[:emi]).to eq 370.20

      interests = result[:schedule].pluck(:interest)
      expected = [95, 89, 86, 83, 79, 76, 73, 69, 66, 62, 59, 55, 51, 48, 44, 40, 36, 32, 29, 25, 21, 17, 13, 8, 4]
      expect(interests).to eq expected
    end
  end
end
