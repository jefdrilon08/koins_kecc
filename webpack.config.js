var debug                 = process.env.NODE_ENV !== "production";
var webpack               = require('webpack');
var WebpackNotifierPlugin = require('webpack-notifier');

module.exports = {
  context: __dirname,
  devtool: debug ? "inline-sourcemap" : false,
  entry: {
    MembersFormResignation: "./react/members/FormResignation.js",
    MemberAccountsSavingsIndex: "./react/member_accounts/savings/Index.js",
    AccountingTrialBalance: "./react/accounting/TrialBalance.js",
    AccountingGeneralLedger: "./react/accounting/GeneralLedger.js",
    AccountingEntryForm: "./react/accounting/AccountingEntryForm.js",
    SurveyUI: "./react/administration/surveys/SurveyUI.js",
    SurveyQuestionUI: "./react/administration/surveys/survey_questions/SurveyQuestionUI.js",
    TimeDepositCollectionUI: "./react/time_deposit_collections/TimeDepositCollectionUI.js",
    WithdrawalCollectionUI: "./react/withdrawal_collections/WithdrawalCollectionUI.js",
    InsuranceWithdrawalCollectionUI: "./react/insurance_withdrawal_collections/InsuranceWithdrawalCollectionUI.js",
    InsuranceFundTransferCollectionUI: "./react/insurance_fund_transfer_collections/InsuranceFundTransferCollectionUI.js",
    BranchManager: "./react/administration/users/BranchManager.js",
    BranchLoanProductStats: "./react/dashboard/BranchLoanProductStats.js",
    LoanAccountingEntry: "./react/loans/AccountingEntry.js",
    DashboardMain: "./react/dashboard/Main.js",
    BranchRepaymentReportShow: "./react/data_stores/branch_repayment_reports/Show.js",
    BranchResignationShow: "./react/data_stores/branch_resignations/Show.js",
    SoaExpensesShow: "./react/data_stores/soa_expenses/Show.js",
    SoaLoansShow: "./react/data_stores/soa_loans/Show.js",
    SoaFundsShow: "./react/data_stores/soa_funds/Show.js",
    WatchlistsShow: "./react/data_stores/watchlists/Show.js",
    RepaymentRatesShow: "./react/data_stores/repayment_rates/Show.js",
    ManualAgingShow: "./react/data_stores/manual_aging/Show.js",
    PersonalFundsShow: "./react/data_stores/personal_funds/Show.js",
    XWeeksToPayShow: "./react/data_stores/x_weeks_to_pay/Show.js",
    MonthlyClosingCollectionShow: "./react/monthly_closing_collections/Show.js",
    MonitoringAccountingEntrySubsidiaryBalancing: "./react/monitoring/AccountingEntrySubsidiaryBalancing.js",
    MonitoringAccountingEntryPrecision: "./react/monitoring/AccountingEntryPrecision.js",
    MemberAccountInsuranceStatus: "./react/member_accounts/FetchInsuranceStatus.js",
    IcprShow: "./react/data_stores/icpr/Show.js",
    DashboardMainMii: "./react/dashboard/MainMii.js",
    Insights: "./react/insights/Index.js"
  },
  module: {
    rules: [
      {
        test: /\.js?$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/react"]
          }
        }
      },
      {
        test: /\.css/,
        loaders: ['style-loader', 'css-loader'],
      }
    ]
  },
  optimization: {
    minimize: true
    //minimizer: [new TerserPlugin()],
  },
  output: {
    path: __dirname + "/app/assets/javascripts/",
    filename: "[name].min.react.js", 
  },
  plugins: debug ? [] : [
    new webpack.optimize.OccurrenceOrderPlugin(),
    new WebpackNotifierPlugin({title: 'KOINS Webpack', alwaysNotify: true})
  ],
};
