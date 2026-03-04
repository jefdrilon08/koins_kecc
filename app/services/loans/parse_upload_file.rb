module Loans
  class ParseUploadFile
    REQUIRED_COLUMNS = %w[
      member_id loan_product_id principal num_installments term
    ].freeze

    def initialize(file:)
      @file = file
    end

    def execute!
      loans  = []
      errors = []

      begin
        records, columns = parse_file
      rescue => e
        return { loans: [], columns: [], errors: ["Failed to parse file: #{e.message}"] }
      end

      if records.empty?
        return { loans: [], columns: [], errors: ["File is empty or has no data rows"] }
      end

      missing = REQUIRED_COLUMNS - columns
      if missing.any?
        return { loans: [], columns: columns, errors: ["Missing required columns: #{missing.join(', ')}"] }
      end

      records.each_with_index do |row, i|
        row_data = row.with_indifferent_access
        row_data[:_row_number] = i + 2
        loans << row_data
      end

      { loans: loans, columns: columns, errors: errors }
    end

    private

    def parse_file
      ext = File.extname(@file.original_filename).downcase

      if ext == ".csv"
        parse_csv
      elsif [".xlsx", ".xls"].include?(ext)
        parse_excel
      else
        raise "Unsupported file type: #{ext}"
      end
    end

    def parse_csv
      require "csv"
      content = @file.read.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace)
      parsed  = CSV.parse(content, headers: true, skip_blanks: true)
      columns = parsed.headers.map(&:to_s)
      rows    = parsed.map { |row| row.to_h }
      [rows, columns]
    end

    def parse_excel
      require "roo"
      ext         = File.extname(@file.original_filename).delete(".").to_sym
      spreadsheet = Roo::Spreadsheet.open(@file.tempfile.path, extension: ext)
      sheet       = spreadsheet.sheet(0)
      headers     = sheet.row(1).map { |h| h.to_s.strip }

      rows = (2..sheet.last_row).map do |i|
        row_values = sheet.row(i)
        headers.zip(row_values).to_h
      end

      [rows, headers]
    end
  end
end