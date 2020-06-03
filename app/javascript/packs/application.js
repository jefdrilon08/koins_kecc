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
import BranchManagerComponent from "../components/administration/users/BranchManagerComponent";

// "init" Objects
import PagesLogin from "../pages/Login.js";
import SavingsAccountsShow from "../savings_accounts/Show.js";
import SavingsAccountsShowWithdrawalRequest from "../savings_accounts/ShowWithdrawalRequest.js";
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
import SubsidiaryAdjustmentsIndex from "../models/SubsidiaryAdjustmentsIndex.js";
import SubsidiaryAdjustmentsShow from "../models/SubsidiaryAdjustmentsShow.js";
import BatchMoratoriumAdjustmentsIndex from "../models/BatchMoratoriumAdjustmentsIndex.js";
import BatchMoratoriumAdjustmentsShow from "../models/BatchMoratoriumAdjustmentsShow.js";
import MemberAccountValidationsIndex from "../models/MemberAccountValidationsIndex.js";
import MemberAccountValidationsShow from "../models/MemberAccountValidationsShow.js";
import MemberAccountValidationsForm from "../models/MemberAccountValidationsForm.js";
import ValidationsReport from "../models/ValidationsReport.js";
import AccountingEntriesShow from "../models/AccountingEntriesShow.js";
import InsuranceAccountStatusIndex from "../models/InsuranceAccountStatusIndex.js";
import Seriatim from "../models/Seriatim.js";
import ClaimsIndex from "../models/ClaimsIndex.js";
import AdministrationUsersIndex from "../models/AdministrationUsersIndex.js";

const renderComponent = (Component, payload) => {
  ReactDOM.render(
    <Component {...payload} />,
    document.getElementById("react-root"),
  )
}

const hooks = {
  "members/form":                                   [MembersFormDisplay],
  "members/index":                                  [MembersIndex],
  "members/show":                                   [MembersShow],
  "members/survey_answer":                          [SurveyAnswer],
  "members/survey_answer_form":                     [SurveyAnswerUIDisplay],
  "pages/index":                                    [DashboardMainUI],
  "pages/login":                                    [PagesLogin],
  "savings_accounts/show":                          [SavingsAccountsShow],
  "savings_accounts/time_deposit_withdrawal":       [SavingsAccountsShowWithdrawalRequest],
  "accounting/crb":                                 [AccountingBooksIndex],
  "accounting/cdb":                                 [AccountingBooksIndex],
  "accounting/jvb":                                 [AccountingBooksIndex],
  "accounting/misc":                                [AccountingBooksIndex],
  "accounting/accounting_codes/index":              [AccountingCodesIndex],
  "loans/show":                                     [LoansShow, LoanAccountingEntryComponent],
  "loans/form":                                     [LoanApplicationForm],
  "billings/index":                                 [BillingsIndex],
  "billings/show":                                  [BillingsShow, BillingUIComponent],
  "membership_payment_collections/index":           [MembershipPaymentCollectionsIndex],
  "membership_payment_collections/show":            [MembershipPaymentCollectionsShow, MembershipPaymentCollectionUIComponent],
  "deposit_collections/index":                      [DepositCollectionsIndex],
  "deposit_collections/show":                       [DepositCollectionsShow, DepositCollectionUIComponent],
  "time_deposit_collections/index":                 [TimeDepositCollectionsIndex],
  "time_deposit_collections/show":                  [TimeDepositCollectionsShow, TimeDepositCollectionUIComponent],
  "withdrawal_collections/index":                   [WithdrawalCollectionsIndex],
  "withdrawal_collections/show":                    [WithdrawalCollectionsShow, WithdrawalCollectionUIComponent],
  "savings_insurance_transfer_collections/index":   [SavingsInsuranceTransferCollectionsIndex],
  "savings_insurance_transfer_collections/show":    [SavingsInsuranceTransferCollectionsShow],
  "insurance_fund_transfer_collections/index":      [InsuranceFundTransferCollectionsIndex],
  "insurance_fund_transfer_collections/show":       [InsuranceFundTransferCollectionsShow, InsuranceFundTransferCollectionUIComponent],
  "insurance_withdrawal_collections/index":         [InsuranceWithdrawalCollectionsIndex],
  "insurance_withdrawal_collections/show":          [InsuranceWithdrawalCollectionsShow, InsuranceWithdrawalCollectionUIComponent],
  "monthly_closing_collections/index":              [MonthlyClosingCollectionsIndex],
  "monthly_closing_collections/show":               [MonthlyClosingCollectionsShow, MonthlyClosingCollectionsShowUI],
  "insurance_accounts/show":                        [InsuranceStatusComponent],
  "accounting/trial_balance":                       [TrialBalanceComponent],
  "accounting/general_ledger":                      [GeneralLedgerComponent],
  "accounting/accounting_entries/form":             [AccountingEntryFormComponent],
  "accounting/year_end_closings/index":             [YearEndClosingsIndex],
  "accounting/year_end_closings/show":              [YearEndClosingsShow],
  "data_stores/icpr/index":                         [DataStoresIcprIndex],
  "data_stores/icpr/show":                          [DataStoresIcprShow, DataStoresIcprShowComponent],
  "data_stores/patronage_refund/index":             [PatronageRefundIndex],
  "data_stores/patronage_refund/show":              [PatronageRefundShow],
  "accounting/balance_sheets/index":                [BalanceSheetsIndex],
  "accounting/income_statements/index":             [IncomeStatementsIndex],
  "adjustments/subsidiary_adjustments/index":       [SubsidiaryAdjustmentsIndex],
  "adjustments/subsidiary_adjustments/show":        [SubsidiaryAdjustmentsShow],
  "adjustments/batch_moratorium_adjustments/index": [BatchMoratoriumAdjustmentsIndex],
  "adjustments/batch_moratorium_adjustments/show":  [BatchMoratoriumAdjustmentsShow],
  "member_account_validations/index":               [MemberAccountValidationsIndex],
  "member_account_validations/show":                [MemberAccountValidationsShow],
  "member_account_validations/edit":                [MemberAccountValidationsForm],
  "pages/validations":                              [ValidationsReport],
  "accounting/accounting_entries/show":             [AccountingEntriesShow],
  "pages/daily_report_insurance_account_status":    [InsuranceAccountStatusIndex],
  "pages/seriatim":                                 [Seriatim],
  "claims/index":                                   [ClaimsIndex],
  "administration/users/index":                     [AdministrationUsersIndex],
  "administration/users/show":                      [BranchManagerComponent]
}

document.addEventListener("DOMContentLoaded", () => {
  const { route, payload } = JSON.parse($("meta[name='parameters']").attr('content'));
  const authenticityToken = $("meta[name='csrf-token']").attr('content');
  const options = { authenticityToken, ...payload }

  console.log("payload:");
  console.log(payload);
  console.log("route: " + route);

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
