var debug                 = process.env.NODE_ENV !== "production";
var webpack               = require('webpack');
var WebpackNotifierPlugin = require('webpack-notifier');

module.exports = {
  context: __dirname,
  devtool: debug ? "inline-sourcemap" : null,
  entry: {
    MembersIndex: "./react/members/Index.js",
    MembersForm: "./react/members/Form.js",
    MembersFormResignation: "./react/members/FormResignation.js",
    MemberAccountsSavingsIndex: "./react/member_accounts/savings/Index.js",
    AccountingTrialBalance: "./react/accounting/TrialBalance.js",
    AccountingGeneralLedger: "./react/accounting/GeneralLedger.js",
    AccountingEntryForm: "./react/accounting/AccountingEntryForm.js",
    BillingUI: "./react/billings/BillingUI.js",
    SurveyUI: "./react/administration/surveys/SurveyUI.js",
    SurveyQuestionUI: "./react/administration/surveys/survey_questions/SurveyQuestionUI.js",
    MembershipPaymentCollectionUI: "./react/membership_payment_collections/MembershipPaymentCollectionUI.js",
    DepositCollectionUI: "./react/deposit_collections/DepositCollectionUI.js",
    WithdrawalCollectionUI: "./react/withdrawal_collections/WithdrawalCollectionUI.js",
    BranchManager: "./react/administration/users/BranchManager.js",
    BranchLoanProductStats: "./react/dashboard/BranchLoanProductStats.js",
    LoanApplicationForm: "./react/loans/ApplicationForm.js",
    LoanAccountingEntry: "./react/loans/AccountingEntry.js",
    MemberSurveyAnswerUI: "./react/members/SurveyAnswerUI.js",
    DashboardMain: "./react/dashboard/Main.js",
    BranchRepaymentReportShow: "./react/data_stores/branch_repayment_reports/Show.js",
    MonthlyClosingCollectionShow: "./react/monthly_closing_collections/Show.js"
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
  output: {
    path: __dirname + "/app/assets/javascripts/",
    filename: "[name].min.react.js", 
  },
  plugins: debug ? [] : [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.optimize.UglifyJsPlugin({ mangle: true, sourcemap: false }),
    new WebpackNotifierPlugin({title: 'KOINS Webpack', alwaysNotify: true})
  ],
};
