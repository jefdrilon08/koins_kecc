var debug                 = process.env.NODE_ENV !== "production";
var webpack               = require('webpack');
var WebpackNotifierPlugin = require('webpack-notifier');

module.exports = {
  context: __dirname,
  devtool: debug ? "inline-sourcemap" : false,
  entry: {
    MembersFormResignation:                       "./app/assets/javascript/components/members/FormResignation.js",
    MemberAccountsSavingsIndex:                   "./app/assets/javascript/components/member_accounts/savings/Index.js",
    SurveyUI:                                     "./app/assets/javascript/components/administration/surveys/SurveyUI.js",
    SurveyQuestionUI:                             "./app/assets/javascript/components/administration/surveys/survey_questions/SurveyQuestionUI.js",
    BranchLoanProductStats:                       "./app/assets/javascript/components/dashboard/BranchLoanProductStats.js",
    LoanAccountingEntry:                          "./app/assets/javascript/components/loans/AccountingEntry.js",
    DashboardMain:                                "./app/assets/javascript/components/dashboard/Main.js",
    BranchRepaymentReportShow:                    "./app/assets/javascript/components/data_stores/branch_repayment_reports/Show.js",
    BranchResignationShow:                        "./app/assets/javascript/components/data_stores/branch_resignations/Show.js",
    SoaExpensesShow:                              "./app/assets/javascript/components/data_stores/soa_expenses/Show.js",
    SoaLoansShow:                                 "./app/assets/javascript/components/data_stores/soa_loans/Show.js",
    SoaFundsShow:                                 "./app/assets/javascript/components/data_stores/soa_funds/Show.js",
    WatchlistsShow:                               "./app/assets/javascript/components/data_stores/watchlists/Show.js",
    RepaymentRatesShow:                           "./app/assets/javascript/components/data_stores/repayment_rates/Show.js",
    ManualAgingShow:                              "./app/assets/javascript/components/data_stores/manual_aging/Show.js",
    PersonalFundsShow:                            "./app/assets/javascript/components/data_stores/personal_funds/Show.js",
    XWeeksToPayShow:                              "./app/assets/javascript/components/data_stores/x_weeks_to_pay/Show.js",
    MonitoringAccountingEntrySubsidiaryBalancing: "./app/assets/javascript/components/monitoring/AccountingEntrySubsidiaryBalancing.js",
    MonitoringAccountingEntryPrecision:           "./app/assets/javascript/components/monitoring/AccountingEntryPrecision.js",
    DashboardMainMii:                             "./app/assets/javascript/components/dashboard/MainMii.js"
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
