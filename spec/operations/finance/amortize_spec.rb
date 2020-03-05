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
      expect(result[:interest]).to eq 1_250
      expect(result[:total_due]).to eq 9_250
      expect(result[:periodic_interest]).to eq 0.0115
      expect(result[:emi]).to eq 370

      ap result
      interests = result[:schedule].pluck(:interest)
      expected = [89, 86, 84.0, 83, 79, 76, 73, 69, 66, 62, 59, 55, 51, 48, 44, 40, 36, 33, 29, 25, 21, 17, 13, 8, 4]
      expect(interests).to eq expected
    end

    specify "principal and interest values are correct" do
      principal = 6_000
      interest  = 950
      params = {
        principal: 6_000,
        annual_interest_rate: 0.6,
        num_installments: 25,
        term: "weekly",
      }

      result = described_class.new(params: params).execute!
      expect(result[:principal]).to eq 6_000
      expect(result[:interest]).to eq 950
    end
  end
end
