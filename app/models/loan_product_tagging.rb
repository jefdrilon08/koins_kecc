class LoanProductTagging < ApplicationRecord
  belongs_to :loan_product
  def to_s
    name
  end
end
