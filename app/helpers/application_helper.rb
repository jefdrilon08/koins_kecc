module ApplicationHelper
  def development?
    ENV['RAILS_ENV'] == 'development'
  end

  def debug?
    development? and params[:debug].present?
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
