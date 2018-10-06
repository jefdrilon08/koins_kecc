module ApplicationHelper
  def accounting_entry_context_class(book)
    if book == "CRB"
      return "bg-success"
    elsif book == "CDB"
      return "bg-warning"
    elsif book == "JVB"
      return "bg-info"
    end
  end
end
