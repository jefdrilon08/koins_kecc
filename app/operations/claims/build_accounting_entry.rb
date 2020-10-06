module Claims
  class BuildAccountingEntry
    include ActionView::Helpers::NumberHelper

    def initialize(config:)
      @config                       = config

      @user                         = @config[:user]
      @claim                        = @config[:claim]
      @branch                       = Branch.where(id: Settings.try(:defaults).try(:default_branch).try(:id)).first
      @claim_data                   = @claim.data.with_indifferent_access

      @particular                   = build_particular
      @payee                        = build_payee

      @current_date                 = ::Utils::GetCurrentDate.new(
                                      config: {
                                        branch: @branch
                                      }
                                    ).execute!
      if config[:data].present?
        @data                       = @config[:data].with_indifferent_access
      end

      @book                         = 'JVB'
      @accounting_fund_id           = ""
 
      if @claim.blip?
        @accounting_fund_id         = AccountingFund.where(name: "Mutual Benefit Fund").first.id
      elsif @claim.clip? || @claim.hiip?
        @accounting_fund_id         = AccountingFund.where(name: "Optional Fund").first.id
      else
        @accounting_fund_id         = AccountingFund.where(name: "General Fund").first.id
      end

      if @claim.pending? || @claim.approved? || @claim.for_posting? || @claim.for_approval?
          @accounting_entry_data  = {
            book: @book,
            date_prepared: @current_date.strftime("%B %d, %Y"),
            company_name: Settings.company_name,
            company_address: Settings.company_address,
            branch: @branch.to_s.upcase,
            prepared_by: @user.print_full_name.titleize,
            particular: @particular,
            debit_journal_entries: [],
            credit_journal_entries: [],
            journal_entries: [],
            branch_id: @branch.id,
            branch_name: @branch.name,
            status: "display",
            accounting_fund_id: @accounting_fund_id,
            data: {
              or_number: "",
              ar_number: "",
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: @payee

            }
          }
      end
    end

    def execute!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_entries
      @accounting_entry_data[:credit_journal_entries] = build_credit_entries

      # Build journal entries
      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount],
          code: j[:code]
        }
      end

      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount],
          code: j[:code]
        }
      end

      @accounting_entry_data
    end

    private

    def build_payee
      payee = ""

      if @claim.blip? || @claim.clip?
        payee = "#{@claim_data[:beneficiary]}"
      elsif @claim.calamity? || @claim.kbente? || @claim.kjsp? || @claim.kalinga?
        payee = "#{@claim_data[:name_of_beneficiary]}"
      elsif @claim.hiip?
        payee = "#{@claim_data[:name_of_beneficiary]}"
      end

      payee
    end

    def build_particular
      branch = @claim.branch
        
      if @claim.blip? 
        if @claim_data[:classification_of_insured] == "Member"
          particular = "Death benefit of #{@claim.member.full_name}, member and his/her claimant is #{@claim_data[:beneficiary]} from #{branch.name}"
        else
          if @claim_data[:classification_of_insured] == "Legal Dependent (Spouse)"
            particular = "Death benefit of #{@claim_data[:name_of_insured]}, spouse of #{@claim.member.full_name} from #{branch.name}"
          elsif @claim_data[:classification_of_insured] == "Legal Dependent (Child)"
            particular = "Death benefit of #{@claim_data[:name_of_insured]}, mother of #{@claim.member.full_name} from #{branch.name}"
          elsif @claim_data[:classification_of_insured] == "Legal Dependent (Parent)"
            particular = "Death benefit of #{@claim_data[:name_of_insured]}, parent of #{@claim.member.full_name} from #{branch.name}"
          end
        end
      elsif @claim.clip?
        particular = "CLIP claim of #{@claim.member.full_name}, payable to #{@claim_data[:beneciary]} for #{@claim_data[:type_of_loan]} : #{@claim_data[:amount]} amount payble to beneciary , #{@claim_data[:amount_payable_to_creditor]} amount payable to #{@claim_data[:creditors_name]}"
      elsif @claim.hiip?
        particular = "HIIP claim of #{@claim.member.full_name} from #{branch.name}"
      elsif @claim.kbente?
        particular = "Claims on K-bente of #{@claim.member.full_name} (Member & Brother) of #{@claim_data[:name_of_insured]} from #{branch.name}"
      elsif @claim.calamity?
        particular = "Calamity Assistance of #{@claim.member.full_name} from #{branch.name} due to #{@claim_data[:type_of_calamity]}"
      elsif @claim.kalinga?
        particular = "K-Kalinga Assistance of #{@claim.member.full_name} from #{branch.name} due to #{@claim_data[:reason_of_death]}"
      elsif @claim.kjsp?
        if @claim_data[:sem].present?
          particular = "KJSP Allowance for #{@claim_data[:name_of_beneficiary]} (Son/Daughter) of #{@claim.member.full_name}(Mother) from #{branch.name} for #{@claim_data[:sem]} Sem SY #{@claim_data[:school_year]}"
        else
          particular = "KJSP Allowance for #{@claim_data[:name_of_beneficiary]} (Son/Daughter) of #{@claim.member.full_name}(Mother) from #{branch.name} for SY #{@claim_data[:school_year]}"
        end
      end

      particular
    end

    def build_debit_entries
      journal_entries = []

      if @claim.blip?
        if @claim_data[:arrears].to_f > 0
          compute_blip_debit_with_arrears.each do |o|
            journal_entries << o
          end          
        end

        compute_blip_debit.each do |o|
          journal_entries << o
        end
      elsif @claim.clip?
        compute_clip_debit.each do |o|
          journal_entries << o
        end
      elsif @claim.hiip?
        compute_hiip_debit.each do |o|
          journal_entries << o
        end
      elsif @claim.kbente?
        compute_kbente_debit.each do |o|
          journal_entries << o
        end
      elsif @claim.kalinga?
        compute_kalinga_debit.each do |o|
          journal_entries << o
        end
      elsif @claim.calamity?
        compute_calamity_debit.each do |o|
          journal_entries << o
        end
      elsif @claim.kjsp?
        compute_kjsp_debit.each do |o|
          journal_entries << o
        end
      end
      
      journal_entries
    end

    def build_credit_entries
      journal_entries = []

      if @claim.blip?
        if @claim_data[:arrears].to_f > 0
          compute_blip_credit_with_arrears.each do |o|
            journal_entries << o
          end          
        end

        compute_blip_credit.each do |o|
          journal_entries << o
        end
      elsif @claim.clip?
        compute_clip_credit.each do |o|
          journal_entries << o
        end
      elsif @claim.hiip?
        compute_hiip_credit.each do |o|
          journal_entries << o
        end
      elsif @claim.kbente?
        compute_kbente_credit.each do |o|
          journal_entries << o
        end
      elsif @claim.kalinga?
        compute_kalinga_credit.each do |o|
          journal_entries << o
        end
      elsif @claim.calamity?
        compute_calamity_credit.each do |o|
          journal_entries << o
        end
      elsif @claim.kjsp?
        compute_kjsp_credit.each do |o|
          journal_entries << o
        end
      end      

      journal_entries
    end

    # FOR BLIP DEBIT
    def compute_blip_debit
      journal_entries = []

      amount = @claim_data[:amount].to_f

      # TODO: Make this configurable
      dr_accounting_code = AccountingCode.find("a14a60e2-e267-41a7-81c3-390a9b1aadba")
    
      if amount > 0
        journal_entries << {
          accounting_code_id: dr_accounting_code.id,
          code: dr_accounting_code.code,
          name: dr_accounting_code.name,
          amount: amount
        }
      end
      
      journal_entries
    end

    # FOR BLIP DEBIT IF HAVE ARREARS
    def compute_blip_debit_with_arrears
      journal_entries = []

      cr_accounting_code  = AccountingCode.find("da7a9fa2-6b75-48a3-83f9-4c40347ab405")

      amount = @claim_data[:arrears].to_f / 2

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    # FOR BLIP CREDIT
    def compute_blip_credit
      journal_entries = []

      cr_accounting_code  = AccountingCode.find("3f2d41e6-415a-4619-89d7-1ea2cbcc535e")

      if !@data.nil?
        if @data[:claims_template].present?
          Settings.claims_templates.each do |template|
            if template.name == @data[:claims_template]
              template.accounting_codes.each do |a|
                cr_accounting_code = AccountingCode.find(a.cr_accounting_code_id)
              end
            end
          end
        end
      end

      if @claim_data[:arrears].to_f > 0 
        half_arrears = @claim_data[:arrears].to_f / 2
        amount = @claim_data[:amount].to_f - half_arrears
      else
        amount = @claim_data[:amount].to_f
      end

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    # FOR BLIP CREDIT IF HAVE ARREARS
    def compute_blip_credit_with_arrears
      journal_entries = []

      cr_accounting_code  = AccountingCode.find("87286b3b-7ca8-4ba4-a377-292a34c5e011")

      amount = @claim_data[:arrears].to_f

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    # FOR CLIP DEBIT
    def compute_clip_debit
      journal_entries = []

      amount = @claim_data[:amount_payable_to_creditor].to_f + @claim_data[:amount].to_f

      # TODO: Make this configurable
      dr_accounting_code = AccountingCode.find("020bb68c-a389-4bb7-9e6d-23fe30f51574")
    
      if amount > 0
        journal_entries << {
          accounting_code_id: dr_accounting_code.id,
          code: dr_accounting_code.code,
          name: dr_accounting_code.name,
          amount: amount
        }
      end
      
      journal_entries
    end

    # FOR CLIP CREDIT
    def compute_clip_credit
      journal_entries = []

      cr_accounting_code  = AccountingCode.find("18edb2e9-0843-4110-8d47-7f72750e8dd2")

      if !@data.nil?
        if @data[:claims_template].present?
          Settings.claims_templates.each do |template|
            if template.name == @data[:claims_template]
              template.accounting_codes.each do |a|
                cr_accounting_code = AccountingCode.find(a.cr_accounting_code_id)
              end
            end
          end
        end
      end

      amount = @claim_data[:amount_payable_to_creditor].to_f + @claim_data[:amount].to_f

      if @claim_data[:arrears].to_f > 0
        amount = amount - @claim_data[:arrears].to_f
      end

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    # FOR HIIP DEBIT
    def compute_hiip_debit
      journal_entries = []

      amount = @claim_data[:amount].to_f

      # TODO: Make this configurable
      dr_accounting_code = AccountingCode.find("9439075e-74e9-4469-8040-0685ea97d027")
    
      if amount > 0
        journal_entries << {
          accounting_code_id: dr_accounting_code.id,
          code: dr_accounting_code.code,
          name: dr_accounting_code.name,
          amount: amount
        }
      end
      
      journal_entries
    end

    # FOR HIIP CREDIT
    def compute_hiip_credit
      journal_entries = []

      cr_accounting_code  = AccountingCode.find("18edb2e9-0843-4110-8d47-7f72750e8dd2")

      if !@data.nil?
        if @data[:claims_template].present?
          Settings.claims_templates.each do |template|
            if template.name == @data[:claims_template]
              template.accounting_codes.each do |a|
                cr_accounting_code = AccountingCode.find(a.cr_accounting_code_id)
              end
            end
          end
        end
      end

      amount = @claim_data[:amount].to_f

      if @claim_data[:arrears].to_f > 0
        amount = amount - @claim_data[:arrears].to_f
      end

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    # FOR KBENTE DEBIT
    def compute_kbente_debit
      journal_entries = []

      amount = @claim_data[:amount].to_f

      # TODO: Make this configurable
      dr_accounting_code = AccountingCode.find("322e3f17-a5b5-4711-bb49-c3a5b1a144f3")
    
      if amount > 0
        journal_entries << {
          accounting_code_id: dr_accounting_code.id,
          code: dr_accounting_code.code,
          name: dr_accounting_code.name,
          amount: amount
        }
      end
      
      journal_entries
    end

    # FOR KBENTE CREDIT
    def compute_kbente_credit
      journal_entries = []

      cr_accounting_code  = AccountingCode.find("9e26384f-7a27-4e89-b5d0-1017cfdccf0b")

      if !@data.nil?
        if @data[:claims_template].present?
          Settings.claims_templates.each do |template|
            if template.name == @data[:claims_template]
              template.accounting_codes.each do |a|
                cr_accounting_code = AccountingCode.find(a.cr_accounting_code_id)
              end
            end
          end
        end
      end

      amount = @claim_data[:amount].to_f

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    # FOR KALINGA DEBIT
    def compute_kalinga_debit
      journal_entries = []

      amount = @claim_data[:amount].to_f

      # TODO: Make this configurable
      dr_accounting_code = AccountingCode.find("fd23a08f-6067-49b4-b5aa-a4ea8009388d")
    
      if amount > 0
        journal_entries << {
          accounting_code_id: dr_accounting_code.id,
          code: dr_accounting_code.code,
          name: dr_accounting_code.name,
          amount: amount
        }
      end
      
      journal_entries
    end

    # FOR KALINGA CREDIT
    def compute_kalinga_credit
      journal_entries = []

      cr_accounting_code  = AccountingCode.find("9e26384f-7a27-4e89-b5d0-1017cfdccf0b")

      if !@data.nil?
        if @data[:claims_template].present?
          Settings.claims_templates.each do |template|
            if template.name == @data[:claims_template]
              template.accounting_codes.each do |a|
                cr_accounting_code = AccountingCode.find(a.cr_accounting_code_id)
              end
            end
          end
        end
      end

      amount = @claim_data[:amount].to_f

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    # FOR CALAMITY DEBIT
    def compute_calamity_debit
      journal_entries = []

      amount = @claim_data[:amount].to_f

      # TODO: Make this configurable
      dr_accounting_code = AccountingCode.find("588ed36b-8daa-441d-9571-8ddbc6dc12cb")
    
      if amount > 0
        journal_entries << {
          accounting_code_id: dr_accounting_code.id,
          code: dr_accounting_code.code,
          name: dr_accounting_code.name,
          amount: amount
        }
      end
      
      journal_entries
    end

    # FOR CALAMITY CREDIT
    def compute_calamity_credit
      journal_entries = []

      cr_accounting_code  = AccountingCode.find("9e26384f-7a27-4e89-b5d0-1017cfdccf0b")

      if !@data.nil?
        if @data[:claims_template].present?
          Settings.claims_templates.each do |template|
            if template.name == @data[:claims_template]
              template.accounting_codes.each do |a|
                cr_accounting_code = AccountingCode.find(a.cr_accounting_code_id)
              end
            end
          end
        end
      end

      amount = @claim_data[:amount].to_f

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    # FOR KJSP DEBIT
    def compute_kjsp_debit
      journal_entries = []

      amount = @claim_data[:amount].to_f

      # TODO: Make this configurable
      dr_accounting_code = AccountingCode.find("588ed36b-8daa-441d-9571-8ddbc6dc12cb")
    
      if amount > 0
        journal_entries << {
          accounting_code_id: dr_accounting_code.id,
          code: dr_accounting_code.code,
          name: dr_accounting_code.name,
          amount: amount
        }
      end
      
      journal_entries
    end

    # FOR KJSP CREDIT
    def compute_kjsp_credit
      journal_entries = []

      cr_accounting_code  = AccountingCode.find("9e26384f-7a27-4e89-b5d0-1017cfdccf0b")

      if !@data.nil?
        if @data[:claims_template].present?
          Settings.claims_templates.each do |template|
            if template.name == @data[:claims_template]
              template.accounting_codes.each do |a|
                cr_accounting_code = AccountingCode.find(a.cr_accounting_code_id)
              end
            end
          end
        end
      end

      amount = @claim_data[:amount].to_f

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end
  end
end
