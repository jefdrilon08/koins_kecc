module Accounting
  module GeneralLedgers
    class BuildExcel
      def initialize(data:)
        @data = data
        @p    = Axlsx::Package.new

        @start_date = @data["start_date"]
        @end_date   = @data["end_date"]

        @company_name       = Settings.company_name
        @company_address    = Settings.company_address
        @company_tin_number = Settings.company_tin_number

        @branch_name  = @data["branch"]["name"]
      end

      def execute!
        @p.workbook do |wb|
          wb.add_worksheet do |sheet|
            header_cells  = wb.styles.add_style(
                              alignment: {
                                horizontal: :left
                              }, 
                              b: true
                            )

            currency_cells_account_title  = wb.styles.add_style(
                                              alignment: {
                                                horizontal: :right
                                              }, 
                                              bg_color: "ff9933",
                                              b: true, 
                                              format_code: "#,##0.00", 
                                              border: Axlsx::STYLE_THIN_BORDER
                                            )

            nil_style = wb.styles.add_style(
                          bg_color: "ff9933",
                          border: Axlsx::STYLE_THIN_BORDER
                        )

            title_cells = wb.styles.add_style(
                            alignment: {
                              horizontal: :left
                            }, 
                            bg_color: "99ceff", 
                            b: true,
                            border: Axlsx::STYLE_THIN_BORDER
                          )

            account_title = wb.styles.add_style(
                              alignment: {
                                horizontal: :left
                              }, 
                              bg_color: "ff9933", 
                              b: true,
                              border: Axlsx::STYLE_THIN_BORDER
                            )

            def_cell  = wb.styles.add_style(
                          alignment: {
                            horizontal: :left
                          }, 
                          border: Axlsx::STYLE_THIN_BORDER
                        )

            def_currency_cells = wb.styles.add_style(
                                    alignment: {
                                      horizontal: :right
                                    },
                                    format_code: "#,##0.00",
                                    border: Axlsx::STYLE_THIN_BORDER
                                  )

            ending_cell = wb.styles.add_style(
                            alignment: {
                              horizontal: :left
                            },
                            bg_color: "66ff66",
                            b: true, 
                            border: Axlsx::STYLE_THIN_BORDER
                          )

            nil_ending_balance = wb.styles.add_style(
                                    bg_color: "66ff66", 
                                    border: Axlsx::STYLE_THIN_BORDER
                                  )

            currency_ending = wb.styles.add_style(
                                alignment: {
                                  horizontal: :right
                                }, 
                                bg_color: "66ff66", 
                                format_code: "#,##0.00",
                                b: true, 
                                border: Axlsx::STYLE_THIN_BORDER
                              )

            center  = wb.styles.add_style(
                        alignment: {
                          horizontal: :center
                        }
                      )

            # Populating the sheet
            sheet.add_row ["GENERAL LEDGER"], style: header_cells
            sheet.add_row ["#{@company_name}"], style: header_cells
            sheet.add_row ["#{@company_address}"], style: header_cells
            sheet.add_row ["TIN Number: #{@company_tin_number}"], style: header_cells
            sheet.add_row ["#{@start_date} - #{@end_date}"], style: header_cells
            sheet.add_row ["#{@branch_name}"], style: header_cells
            sheet.add_row [""]

            sheet.add_row(
              ["DATE", "REFERENCE NUMBER", "SUB REFERENCE NUMBER", "BOOK", "PARTICULAR", "DEBIT", "CREDIT", ""], 
              style: title_cells
            )

            @data["entries"].each do |entry|
              sheet.add_row(
                ["#{entry["accounting_code_name"]}", "", "", "", "", "", "", "#{entry["beginning_balance"]}"], 
                style: [account_title, nil_style, nil_style, nil_style, nil_style, nil_style, nil_style, currency_cells_account_title]
              )

              entry["entries"].each do |sub_entry|
                sheet.add_row(
                  [
                    "#{sub_entry["date_posted"]}",
                    "#{sub_entry["reference_number"].rjust(10,'0')}",
                    "#{sub_entry["sub_reference_number"]}",
                    "#{sub_entry["book"]}",
                    "#{sub_entry["particular"]}",
                    "#{sub_entry["dr_amount"]}",
                    "#{sub_entry["cr_amount"]}",
                    "#{sub_entry["running_balance"]}"
                  ],
                  style: [
                    def_cell,
                    def_cell,
                    def_cell,
                    def_cell,
                    def_cell,
                    def_currency_cells,
                    def_currency_cells,
                    def_currency_cells
                  ]
                )
              end

              sheet.add_row(
                [
                  "#{entry["accounting_code_name"]} - ENDING BALANCE","","","","","","","#{entry["ending_balance"]}"
                ], 
                style: [
                  ending_cell,
                  nil_ending_balance,
                  nil_ending_balance,
                  nil_ending_balance,
                  nil_ending_balance,
                  nil_ending_balance,
                  nil_ending_balance,
                  currency_ending
                ]
              )
            end
          end
        end

        @p  
      end
    end
  end
end
