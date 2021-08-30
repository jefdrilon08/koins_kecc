require("@rails/ujs").start();

import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

import 'bootstrap';
import jquery from 'jquery';
import $ from 'jquery';

window.$ = window.jquery = jquery;

import "@fortawesome/fontawesome-free/js/all";

import '@coreui/coreui';

import "../stylesheets/application.scss";

// React Components
import DashboardMainUI from "../components/dashboard/MainUI";
import MembersFormDisplay from "../components/members/FormDisplay";
import SurveyAnswerUIDisplay from "../components/members/SurveyAnswerUIDisplay";
import LoanApplicationForm from "../components/loans/ApplicationFormComponent";
import LoanAccountingEntryComponent from "../components/loans/AccountingEntryComponent";
import BillingUIComponent from "../components/billings/BillingUIComponent";
import MembershipPaymentCollectionUIComponent from "../components/membership_payment_collections/MembershipPaymentCollectionUIComponent";
import DepositCollectionUIComponent from "../components/deposit_collections/DepositCollectionUIComponent";
import TimeDepositCollectionUIComponent from "../components/time_deposit_collections/TimeDepositCollectionUIComponent";
import WithdrawalCollectionUIComponent from "../components/withdrawal_collections/WithdrawalCollectionUIComponent";
import InsuranceFundTransferCollectionUIComponent from "../components/insurance_fund_transfer_collections/InsuranceFundTransferCollectionUIComponent";
import InsuranceWithdrawalCollectionUIComponent from "../components/insurance_withdrawal_collections/InsuranceWithdrawalCollectionUIComponent";
import MonthlyClosingCollectionsShowUI from "../components/monthly_closing_collections/ShowUI";
import InsuranceStatusComponent from "../components/member_accounts/InsuranceStatusComponent";
import TrialBalanceComponent from "../components/accounting/TrialBalanceComponent";
import GeneralLedgerComponent from "../components/accounting/GeneralLedgerComponent";
import AccountingEntryFormComponent from "../components/accounting/AccountingEntryFormComponent";
import DataStoresIcprShowComponent from "../components/data_stores/icpr/ShowComponent";
import DataStoresPatronageRefundShowComponent from "../components/data_stores/patronage_refund/ShowComponent";
import BranchManagerComponent from "../components/administration/users/BranchManagerComponent";
import SurveyQuestionUIComponent from "../components/administration/surveys/survey_questions/SurveyQuestionUIComponent.js";
import RepaymentRatesShowComponent from "../components/data_stores/repayment_rates/ShowComponent.js";
import ManualAgingShowComponent from "../components/data_stores/manual_aging/ShowComponent.js";
import PersonalFundsShowComponent from "../components/data_stores/personal_funds/ShowComponent.js";
import SOAExpensesShowComponent from "../components/data_stores/soa_expenses/ShowComponent.js";
import SOALoansShowComponent from "../components/data_stores/soa_loans/ShowComponent.js";
import SOAFundsShowComponent from "../components/data_stores/soa_funds/ShowComponent.js";
import WatchlistsShowComponent from "../components/data_stores/watchlists/ShowComponent.js";
import XWeeksToPayShowComponent from "../components/data_stores/x_weeks_to_pay/ShowComponent.js";
import BranchResignationsShowComponent from "../components/data_stores/branch_resignations/ShowComponent.js";
import AccountingEntrySubsidiaryBalancingComponent from "../components/monitoring/AccountingEntrySubsidiaryBalancingComponent.js";
import AccountingEntryPrecisionComponent from "../components/monitoring/AccountingEntryPrecisionComponent.js";
import FormResignationComponent from "../components/members/FormResignationComponent.js";
import EquityWithdrawalCollectionUIComponent from "../components/equity_withdrawal_collections/EquityWithdrawalCollectionUIComponent.js";
import GeneralLedgerDisplayComponent from "../components/accounting/GeneralLedgerDisplayComponent.js";

// "init" Objects
import PagesLogin from "../models/PagesLogin.js";
import SavingsAccountsShow from "../models/SavingsAccountsShow.js";
import SavingsAccountsShowWithdrawalRequest from "../models/ShowWithdrawalRequest.js";
import AccountingCodesIndex from "../models/AccountingCodesIndex.js";
import AccountingBooksIndex from "../models/AccountingBooksIndex.js";
import LoansShow from "../models/LoansShow.js";
import BillingsIndex from "../models/BillingsIndex.js";
import BillingsShow from "../models/BillingsShow.js";
import MembershipPaymentCollectionsIndex from "../models/MembershipPaymentCollectionsIndex.js";
import MembershipPaymentCollectionsShow from "../models/MembershipPaymentCollectionsShow.js";
import DepositCollectionsIndex from "../models/DepositCollectionsIndex.js";
import DepositCollectionsShow from "../models/DepositCollectionsShow.js";
import TimeDepositCollectionsIndex from "../models/TimeDepositCollectionsIndex.js";
import TimeDepositCollectionsShow from "../models/TimeDepositCollectionsShow.js";
import WithdrawalCollectionsIndex from "../models/WithdrawalCollectionsIndex.js";
import WithdrawalCollectionsShow from "../models/WithdrawalCollectionsShow.js";
import MembersIndex from "../models/MembersIndex.js";
import MembersShow from "../models/MembersShow.js";
import SurveyAnswer from "../models/SurveyAnswer.js";
import SavingsInsuranceTransferCollectionsIndex from "../models/SavingsInsuranceTransferCollectionsIndex.js";
import SavingsInsuranceTransferCollectionsShow from "../models/SavingsInsuranceTransferCollectionsShow.js";
import InsuranceFundTransferCollectionsIndex from "../models/InsuranceFundTransferCollectionsIndex.js";
import InsuranceFundTransferCollectionsShow from "../models/InsuranceFundTransferCollectionsShow.js";
import InsuranceWithdrawalCollectionsIndex from "../models/InsuranceWithdrawalCollectionsIndex.js";
import InsuranceWithdrawalCollectionsShow from "../models/InsuranceWithdrawalCollectionsShow.js";
import MonthlyClosingCollectionsIndex from "../models/MonthlyClosingCollectionsIndex.js";
import MonthlyClosingCollectionsShow from "../models/MonthlyClosingCollectionsShow.js";
import YearEndClosingsIndex from "../models/YearEndClosingsIndex.js";
import YearEndClosingsShow from "../models/YearEndClosingsShow.js";
import DataStoresIcprIndex from "../models/DataStoresIcprIndex.js";
import DataStoresIcprShow from "../models/DataStoresIcprShow.js";
import PatronageRefundIndex from "../models/PatronageRefundIndex.js";
import PatronageRefundShow from "../models/PatronageRefundShow.js";
import BalanceSheetsIndex from "../models/BalanceSheetsIndex.js";
import IncomeStatementsIndex from "../models/IncomeStatementsIndex.js";
import SubsidiaryAdjustmentsIndex from "../models/SubsidiaryAdjustmentsIndex.js"; import SubsidiaryAdjustmentsShow from "../models/SubsidiaryAdjustmentsShow.js";
import BatchMoratoriumAdjustmentsIndex from "../models/BatchMoratoriumAdjustmentsIndex.js";
import BatchMoratoriumAdjustmentsShow from "../models/BatchMoratoriumAdjustmentsShow.js";
import MemberAccountValidationsIndex from "../models/MemberAccountValidationsIndex.js";
import MemberAccountValidationsShow from "../models/MemberAccountValidationsShow.js";
import MemberAccountValidationsForm from "../models/MemberAccountValidationsForm.js";
import ClaimsShow from "../models/ClaimsShow.js";
import ValidationsReport from "../models/ValidationsReport.js";
import AccountingEntriesShow from "../models/AccountingEntriesShow.js";
import InsuranceAccountStatusIndex from "../models/InsuranceAccountStatusIndex.js";
import Seriatim from "../models/Seriatim.js";
import AdministrationUsersIndex from "../models/AdministrationUsersIndex.js";
import AdministrationLoanProductsShow from "../models/AdministrationLoanProductsShow.js";
import AdministrationLoanProductsIndex from "../models/AdministrationLoanProductsIndex.js";
import AdministrationAreasIndex from "../models/AdministrationAreasIndex.js";
import AdministrationClustersIndex from "../models/AdministrationClustersIndex.js";
import AdministrationBranchesIndex from "../models/AdministrationBranchesIndex.js";
import AdministrationBranchesShow from "../models/AdministrationBranchesShow.js";
import AdministrationCentersShow from "../models/AdministrationCentersShow.js";
import AdministrationSurveysIndex from "../models/AdministrationSurveysIndex.js";
import AdministrationSurveysShow from "../models/AdministrationSurveysShow.js";
import MemberSharesShow from "../models/MemberSharesShow.js";
import MemberSharesForm from "../models/MemberSharesForm.js";
import ExportsBillingPerCenter from "../models/ExportsBillingPerCenter.js";
import MonthlyNewAndResignedIndex from "../models/MonthlyNewAndResignedIndex.js";
import ExportTools from "../models/ExportTools.js";
import RepaymentRatesIndex from "../models/RepaymentRatesIndex.js";
import ManualAgingIndex from "../models/ManualAgingIndex.js";
import PersonalFundsIndex from "../models/PersonalFundsIndex.js";
import PersonalFundsShow from "../models/PersonalFundsShow.js";
import BranchLoansStatsIndex from "../models/BranchLoansStatsIndex.js";
import BranchLoansStatsShow from "../models/BranchLoansStatsShow.js";
import MemberCountsIndex from "../models/MemberCountsIndex.js";
import MemberCountsShow from "../models/MemberCountsShow.js";
import InsuranceMemberCountsIndex from "../models/InsuranceMemberCountsIndex.js";
import InsuranceMemberCountsShow from "../models/InsuranceMemberCountsShow.js";
import ClaimsCountsIndex from "../models/ClaimsCountsIndex.js";
import ClaimsCountsShow from "../models/ClaimsCountsShow.js";
import AccountingEntriesSummariesIndex from "../models/AccountingEntriesSummariesIndex.js";
import SOAExpensesIndex from "../models/SOAExpensesIndex.js";
import SOALoansIndex from "../models/SOALoansIndex.js";
import SOAFundsIndex from "../models/SOAFundsIndex.js";
import WatchlistsIndex from "../models/WatchlistsIndex.js";
import MonthlyIncentivesIndex from "../models/MonthlyIncentivesIndex.js";
import XWeeksToPayIndex from "../models/XWeeksToPayIndex.js";
import BranchResignationsIndex from "../models/BranchResignationsIndex.js";
import ReportsMonthlyRemittance from "../models/ReportsMonthlyRemittance.js";
import ReportsInsuredLoans from "../models/ReportsInsuredLoans.js";
import ReportsHiipReport from "../models/ReportsHiipReport.js";
import ReportsMemberReports from "../models/ReportsMemberReports.js";
import ReportsCollectionsCLIP from "../models/ReportsCollectionsCLIP.js";
import ReportsCollectionsBLIP from "../models/ReportsCollectionsBLIP.js";
import ReportsMemberDependents from "../models/ReportsMemberDependents.js";
import ReportsMemberQuarterlyReports from "../models/ReportsMemberQuarterlyReports.js";
import ReportsInsuranceQuarterlyReports from "../models/ReportsInsuranceQuarterlyReports.js";
import ReportsMemberCounts from "../models/ReportsMemberCounts.js";
import ReportsCIC from "../models/ReportsCIC.js";
import ReportsMonthlyCollection from "../models/ReportsMonthlyCollection.js";
import ReportsSummaryOfCertificatesAndPolicies from "../models/ReportsSummaryOfCertificatesAndPolicies.js";
import ReportsPersonalDocuments from "../models/ReportsPersonalDocuments.js";
import ReportsClaims from "../models/ReportsClaims.js";
import UserDemeritsShow from "../models/UserDemeritsShow.js";
import EquityWithdrawalCollectionsIndex from "../models/EquityWithdrawalCollectionsIndex.js";
import EquityWithdrawalCollectionsShow from "../models/EquityWithdrawalCollectionsShow.js";
import ClaimsIndex from "../models/ClaimsIndex.js";
import AdjustmentsMoratoriumsIndex from "../models/AdjustmentsMoratoriumsIndex.js";
import ChangePassword from "../models/ChangePassword.js";
import TrialBalancesIndex from "../models/TrialBalancesIndex.js";
import TrialBalancesShow from "../models/TrialBalancesShow.js";
import GeneralLedgersIndex from "../models/GeneralLedgersIndex.js";
import GeneralLedgersShow from "../models/GeneralLedgersShow.js";
import MembersSearch from "../models/MembersSearch.js";
import AdjustmentsAccruedInterestsIndex from "../models/AdjustmentsAccruedInterestsIndex.js";
import AdjustmentsAccruedInterestsShow from "../models/AdjustmentsAccruedInterestsShow.js";
import AccruedPaymentCollectionsIndex  from "../models/AccruedPaymentCollectionsIndex.js";
import AccruedPaymentCollectionsShow  from "../models/AccruedPaymentCollectionsShow.js";
import AdjustmentsRecomputeRestructuresIndex from "../models/AdjustmentsRecomputeRestructuresIndex.js";
import AdjustmentsRecomputeRestructuresShow from "../models/AdjustmentsRecomputeRestructuresShow.js";
import DailyBranchMetricsIndex from "../models/DailyBranchMetricsIndex.js";
import Dashboard from "../models/Dashboard.js";
import MonthlyAccountingCodeSummariesIndex from "../models/MonthlyAccountingCodeSummariesIndex.js";
import TrendsIndex from "../models/TrendsIndex.js";
import OnlineApplicationsShow from "../models/OnlineApplicationsShow.js";
import BillingForFullPaymentsIndex from "../models/BillingForFullPaymentsIndex.js";
import BillingForFullPaymentsShow from "../models/BillingForFullPaymentsShow.js";

const renderComponent = (Component, payload) => {
  ReactDOM.render(
    <Component {...payload} />,
    document.getElementById("react-root"),
  )
}

const hooks = {
  "members/form":                                     [MembersFormDisplay],
  "members/index":                                    [MembersIndex],
  "members/search":                                   [MembersSearch],
  "members/show":                                     [MembersShow],
  "members/survey_answer":                            [SurveyAnswer],
  "members/survey_answer_form":                       [SurveyAnswerUIDisplay],
  "pages/index":                                      [DashboardMainUI, Dashboard],
  "pages/login":                                      [PagesLogin],
  "savings_accounts/show":                            [SavingsAccountsShow],
  "savings_accounts/time_deposit_withdrawal":         [SavingsAccountsShowWithdrawalRequest],
  "accounting/crb":                                   [AccountingBooksIndex],
  "accounting/cdb":                                   [AccountingBooksIndex],
  "accounting/jvb":                                   [AccountingBooksIndex],
  "accounting/misc":                                  [AccountingBooksIndex],
  "accounting/accounting_codes/index":                [AccountingCodesIndex],
  "loans/show":                                       [LoansShow, LoanAccountingEntryComponent],
  "loans/form":                                       [LoanApplicationForm],
  "billings/index":                                   [BillingsIndex],
  "billings/show":                                    [BillingsShow, BillingUIComponent],
  "membership_payment_collections/index":             [MembershipPaymentCollectionsIndex],
  "membership_payment_collections/show":              [MembershipPaymentCollectionsShow, MembershipPaymentCollectionUIComponent],
  "deposit_collections/index":                        [DepositCollectionsIndex],
  "deposit_collections/show":                         [DepositCollectionsShow, DepositCollectionUIComponent],
  "time_deposit_collections/index":                   [TimeDepositCollectionsIndex],
  "time_deposit_collections/show":                    [TimeDepositCollectionsShow, TimeDepositCollectionUIComponent],
  "withdrawal_collections/index":                     [WithdrawalCollectionsIndex],
  "withdrawal_collections/show":                      [WithdrawalCollectionsShow, WithdrawalCollectionUIComponent],
  "savings_insurance_transfer_collections/index":     [SavingsInsuranceTransferCollectionsIndex],
  "savings_insurance_transfer_collections/show":      [SavingsInsuranceTransferCollectionsShow],
  "insurance_fund_transfer_collections/index":        [InsuranceFundTransferCollectionsIndex],
  "insurance_fund_transfer_collections/show":         [InsuranceFundTransferCollectionsShow, InsuranceFundTransferCollectionUIComponent],
  "insurance_withdrawal_collections/index":           [InsuranceWithdrawalCollectionsIndex],
  "insurance_withdrawal_collections/show":            [InsuranceWithdrawalCollectionsShow, InsuranceWithdrawalCollectionUIComponent],
  "monthly_closing_collections/index":                [MonthlyClosingCollectionsIndex],
  "monthly_closing_collections/show":                 [MonthlyClosingCollectionsShow, MonthlyClosingCollectionsShowUI],
  "insurance_accounts/show":                          [InsuranceStatusComponent],
  "accounting/trial_balance":                         [TrialBalanceComponent],
  "accounting/general_ledger":                        [GeneralLedgerComponent],
  "accounting/accounting_entries/form":               [AccountingEntryFormComponent],
  "accounting/year_end_closings/index":               [YearEndClosingsIndex],
  "accounting/year_end_closings/show":                [YearEndClosingsShow],
  "data_stores/icpr/index":                           [DataStoresIcprIndex],
  "data_stores/icpr/show":                            [DataStoresIcprShow, DataStoresIcprShowComponent],
  "data_stores/patronage_refund/index":               [PatronageRefundIndex],
  "data_stores/patronage_refund/show":                [PatronageRefundShow,DataStoresPatronageRefundShowComponent],
  "accounting/balance_sheets/index":                  [BalanceSheetsIndex],
  "accounting/income_statements/index":               [IncomeStatementsIndex],
  "adjustments/subsidiary_adjustments/index":         [SubsidiaryAdjustmentsIndex],
  "adjustments/subsidiary_adjustments/show":          [SubsidiaryAdjustmentsShow],
  "adjustments/batch_moratorium_adjustments/index":   [BatchMoratoriumAdjustmentsIndex],
  "adjustments/batch_moratorium_adjustments/show":    [BatchMoratoriumAdjustmentsShow],
  "adjustments/moratoriums/index":                    [AdjustmentsMoratoriumsIndex],
  "adjustments/accrued_interests/index":              [AdjustmentsAccruedInterestsIndex],
  "adjustments/recompute_restructures/index":         [AdjustmentsRecomputeRestructuresIndex],
  "adjustments/recompute_restructures/show":          [AdjustmentsRecomputeRestructuresShow],
  "accrued_payment_collections/index":                [AccruedPaymentCollectionsIndex],
  "adjustments/accrued_interests/show":               [AdjustmentsAccruedInterestsShow],
  "member_account_validations/index":                 [MemberAccountValidationsIndex],
  "member_account_validations/show":                  [MemberAccountValidationsShow],
  "member_account_validations/edit":                  [MemberAccountValidationsForm],
  "claims/show":                                      [ClaimsShow],
  "pages/validations":                                [ValidationsReport],
  "accounting/accounting_entries/show":               [AccountingEntriesShow],
  "pages/daily_report_insurance_account_status":      [InsuranceAccountStatusIndex],
  "pages/seriatim":                                   [Seriatim],
  "claims/index":                                     [ClaimsIndex],
  "administration/users/index":                       [AdministrationUsersIndex],
  "administration/users/show":                        [BranchManagerComponent],
  "administration/loan_products/show":                [AdministrationLoanProductsShow],
  "administration/loan_products/index":               [AdministrationLoanProductsIndex],
  "administration/areas/index":                       [AdministrationAreasIndex],
  "administration/clusters/index":                    [AdministrationClustersIndex],
  "administration/branches/index":                    [AdministrationBranchesIndex],
  "administration/branches/show":                     [AdministrationBranchesShow],
  "administration/centers/show":                      [AdministrationCentersShow],
  "administration/surveys/index":                     [AdministrationSurveysIndex],
  "administration/surveys/show":                      [AdministrationSurveysShow],
  "administration/surveys/survey_question_form":      [SurveyQuestionUIComponent],
  "members/member_shares/show":                       [MemberSharesShow],
  "members/member_shares/new":                        [MemberSharesForm],
  "pages/billing_per_center":                         [ExportsBillingPerCenter],
  "data_stores/monthly_new_and_resigned/index":       [MonthlyNewAndResignedIndex],
  "pages/export_tools":                               [ExportTools],
  "data_stores/repayment_rates/index":                [RepaymentRatesIndex],
  "data_stores/repayment_rates/show":                 [RepaymentRatesShowComponent],
  "data_stores/manual_aging/index":                   [ManualAgingIndex],
  "data_stores/manual_aging/show":                    [ManualAgingShowComponent],
  "data_stores/personal_funds/index":                 [PersonalFundsIndex],
  "data_stores/personal_funds/show":                  [PersonalFundsShowComponent, PersonalFundsShow],
  "data_stores/branch_loans_stats/index":             [BranchLoansStatsIndex],
  "data_stores/branch_loans_stats/show":              [BranchLoansStatsShow],
  "data_stores/member_counts/index":                  [MemberCountsIndex],
  "data_stores/member_counts/show":                   [MemberCountsShow],
  "data_stores/insurance_member_counts/index":        [InsuranceMemberCountsIndex],
  "data_stores/insurance_member_counts/show":         [InsuranceMemberCountsShow],
  "data_stores/claims_counts/index":                  [ClaimsCountsIndex],
  "data_stores/claims_counts/show":                   [ClaimsCountsShow],
  "data_stores/accounting_entries_summaries/index":   [AccountingEntriesSummariesIndex],
  "data_stores/soa_expenses/index":                   [SOAExpensesIndex],
  "data_stores/soa_expenses/show":                    [SOAExpensesShowComponent],
  "data_stores/soa_loans/index":                      [SOALoansIndex],
  "data_stores/soa_loans/show":                       [SOALoansShowComponent],
  "data_stores/soa_funds/index":                      [SOAFundsIndex],
  "data_stores/soa_funds/show":                       [SOAFundsShowComponent],
  "data_stores/watchlists/index":                     [WatchlistsIndex],
  "data_stores/watchlists/show":                      [WatchlistsShowComponent],
  "data_stores/monthly_incentives/index":             [MonthlyIncentivesIndex],
  "data_stores/x_weeks_to_pay/index":                 [XWeeksToPayIndex],
  "data_stores/x_weeks_to_pay/show":                  [XWeeksToPayShowComponent],
  "data_stores/branch_resignations/index":            [BranchResignationsIndex],
  "data_stores/branch_resignations/show":             [BranchResignationsShowComponent],
  "reports/monthly_remittance":                       [ReportsMonthlyRemittance],
  "reports/insured_loans":                            [ReportsInsuredLoans],
  "reports/hiip_report":                              [ReportsHiipReport],
  "reports/member_reports":                           [ReportsMemberReports],
  "reports/collections_clip":                         [ReportsCollectionsCLIP],
  "reports/collections_blip":                         [ReportsCollectionsBLIP],
  "reports/member_dependents":                        [ReportsMemberDependents],
  "reports/member_quarterly_reports":                 [ReportsMemberQuarterlyReports],
  "reports/insurance_quarterly_reports":              [ReportsInsuranceQuarterlyReports],
  "reports/member_counts":                            [ReportsMemberCounts],
  "reports/cic":                                      [ReportsCIC],
  "reports/monthly_collection":                       [ReportsMonthlyCollection],
  "reports/summary_of_certificates_and_policies":     [ReportsSummaryOfCertificatesAndPolicies],
  "reports/personal_documents":                       [ReportsPersonalDocuments],
  "reports/claims":                                   [ReportsClaims],
  "monitoring/accounting_entry_subsidiary_balancing": [AccountingEntrySubsidiaryBalancingComponent],
  "monitoring/accounting_entry_precision":            [AccountingEntryPrecisionComponent],
  "administration/user_demerits/show":                [UserDemeritsShow],
  "members/form_resignation":                         [FormResignationComponent],
  "equity_withdrawal_collections/index":              [EquityWithdrawalCollectionsIndex],
  "equity_withdrawal_collections/show":               [EquityWithdrawalCollectionsShow, EquityWithdrawalCollectionUIComponent],
  "pages/change_password":                            [ChangePassword],
  "accounting/trial_balances/index":                  [TrialBalancesIndex],
  "accounting/trial_balances/show":                   [TrialBalancesShow],
  "accounting/general_ledgers/index":                 [GeneralLedgersIndex],
  "accounting/general_ledgers/show":                  [GeneralLedgersShow, GeneralLedgerDisplayComponent],
  "daily_branch_metrics/index":                       [DailyBranchMetricsIndex],
  "monthly_accounting_code_summaries/index":          [MonthlyAccountingCodeSummariesIndex],
  "trends/index":                                     [TrendsIndex],
  "online_applications/show":                         [OnlineApplicationsShow],
  "billing_for_full_payments/index":                  [BillingForFullPaymentsIndex],
  "billing_for_full_payments/show":                   [BillingForFullPaymentsShow],
  "accrued_payment_collections/show":                 [AccruedPaymentCollectionsShow]
}

document.addEventListener("DOMContentLoaded", () => {
  const { route, payload } = JSON.parse($("meta[name='parameters']").attr('content'));
  const authenticityToken = $("meta[name='csrf-token']").attr('content');
  const options = { authenticityToken, ...payload }

  const components = hooks[route];
  if (components) {
    components.forEach((component) => {
      if (typeof component.init === "function") {
        // "init" object
        component.init(options)
      } else {
        // React component
        renderComponent(component, options)
      }
    })
  }
});
