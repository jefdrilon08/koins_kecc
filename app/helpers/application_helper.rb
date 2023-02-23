module ApplicationHelper
  def fetch_valid_roles(module_name)
    ::Users::FetchValidRoles.new(
      module_name: module_name
    ).execute!
  end

  def loan_products_for_restructuring
    loan_product_ids = Settings.loan_products.select{ |o| o.for_restructuring == true }.pluck(:loan_product_id)    

    if loan_product_ids.any?
      return LoanProduct.where(id: loan_product_ids)
    else
      []
    end
  end

  def is_mis_user?
    current_user.roles.include?("MIS")
  end

  def is_remote_bk_user?
    current_user.roles.include?("REMOTE-BK")
  end
  
  def sbk_mis_user
    sbk_mis_user = ["SBK","MIS"].include? current_user.roles.last
  end
  
  def bk_mis_user
    bk_mis_user = ["MIS","BK"].include? current_user.roles.last
  end

  def sbk_bk_mis_user
    sbk_bk_mis_user = ["SBK","MIS","BK"].include? current_user.roles.last
  end

  def oas_mis_user
    oas_mis_user = ["OAS","MIS","SO"].include? current_user.roles.last
  end

  def title(*args)
    key = "titles.#{params[:controller].gsub("/", ".")}.#{params[:action]}"
    content_for :title, t(key, title: args.join(" - "))
  end

  # Examples:
  #
  # { "pages" => "about" } -> #about action in PagesController
  # { "pages" => nil } -> any action in PagesController
  # { "a" => ["b", "c"], "d" => nil } -> #b and #c actions in AController, and any action in DController
  def active_class(hash_set, name: "active")
    return if !hash_set

    actions = hash_set[params[:controller]]

    return name if hash_set.key?(params[:controller]) && (actions.nil? || actions&.include?(params[:action]))
  end

  def accounting_funds
    AccountingFund.all.map{ |o|
      {
        id: o.id,
        name: o.name
      }
    }
  end

  def fetch_centers(branch)
    Center.where(branch_id: branch.id).order("name ASC").map { |c|
      {
        id: c.id,
        name: c.name
      }
    }
  end

  def cash_management_templates
    names = []

    if Settings.cash_management_templates.present?
      Settings.cash_management_templates.each do |o|
        names << o.name
      end
    end

    return names
  end

  def claims_templates
    names = []

    if Settings.claims_templates.present?
      Settings.claims_templates.each do |o|
        names << o.name
      end
    end

    return names
  end

  def templates
    names = []

    if Settings.templates.present?
      Settings.templates.each do |o|
        names << o.name
      end
    end

    return names
  end

  def member_resignation_types
    Settings.member_resignation_types.map{ |o|
      {
        name: o.name,
        particulars: o.particulars.map{ |oo|
          {
            code: oo.code,
            name: oo.name
          }
        }
      }
    }
  end

  def resignation_types

    data  = []
    Settings.member_resignation_types.each do |o|
      data << o.name
    end

    data
  end

  def insurance_subtypes
    Settings.default_member_accounts.select{ |o| o.account_type == "INSURANCE" }.map{ |o|
      o.account_subtype
    }
  end

  def savings_subtypes
    data  = []

    Settings.default_member_accounts.each do |o|
      if o.account_type == "SAVINGS"
        data << o.account_subtype
      end
    end

    data
  end

  def equity_subtypes
    data  = []

    Settings.default_member_accounts.each do |o|
      if o.account_type == "EQUITY"
        data << o.account_subtype
      end
    end

    data
  end

  def development?
    ENV['RAILS_ENV'] == 'development'
  end

  def microloans?
    Settings.activate_microloans.present? and Settings.activate_microloans == true
  end

  def microinsurance?
    Settings.activate_microinsurance.present? and Settings.activate_microinsurance == true
  end

  def current_month_start
    d = Date.today
    current_month = d.month - 1
    current_year  = d.year
    Date.civil(current_year, current_month, 1).strftime("%Y-%m-%d")
  end

  def current_month_end
    d = Date.today
    current_month = d.month - 1
    current_year  = d.year
    Date.civil(current_year, current_month, -1).strftime("%Y-%m-%d")
  end

  def debug?
    params[:debug].present?
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
    elsif book == "MISC"
      return "bg-info"
    end
  end

  def accounting_book_mnemonic(book)
    if book == "Cash Receipts"
      return "CRB"
    elsif book == "Cash Disbursements"
      return "CDB"
    elsif book == "Miscellaneous"
      return "MISC"
    else
      return "JVB"
    end
  end

  def tr_status(status)
    if status == "pending"
      'rejected'
    end
  end
  
end
