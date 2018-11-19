module ApplicationHelper
  def development?
    ENV['RAILS_ENV'] == 'development'
  end

  def debug?
    development? and params[:debug].present?
  end

  def payment_modes
    [
      {
        term: "weekly",
        values: [15, 25, 35, 50]
      },
      {
        term: "monthly",
        values: [3, 6, 9, 12]
      },
      {
        term: "semi_monthly",
        values: [6, 12, 18, 24]
      }
    ]
  end

  def accounting_entry_context_class(book)
    if book == "CRB"
      return "bg-success"
    elsif book == "CDB"
      return "bg-warning"
    elsif book == "JVB"
      return "bg-info"
    end
  end

  def accounting_book_mnemonic(book)
    if book == "Cash Receipts"
      return "CRB"
    elsif book == "Cash Disbursements"
      return "CDB"
    else
      return "JVB"
    end
  end
end
