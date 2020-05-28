import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

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

// "init" Objects
import PagesLogin from "../pages/Login.js";
import SavingsAccountsShow from "../savings_accounts/Show.js";
import SavingsAccountsShowWithdrawalRequest from "../savings_accounts/ShowWithdrawalRequest.js";

import "../members/Index.js";
import "../members/Show.js";
import "../members/SurveyAnswer.js";
import "../loans/Show.js";
import "../billings/Index.js";
import "../billings/Show.js";
import "../membership_payment_collections/Index.js";
import "../membership_payment_collections/Show.js";
import "../deposit_collections/Index.js";
import "../deposit_collections/Show.js";
import "../time_deposit_collections/Index.js";
import "../time_deposit_collections/Show.js";
import "../withdrawal_collections/Index.js";
import "../withdrawal_collections/Show.js";
import "../savings_insurance_transfer_collections/Index.js";
import "../savings_insurance_transfer_collections/Show.js";
import "../insurance_fund_transfer_collections/Index.js";
import "../insurance_fund_transfer_collections/Show.js";
import "../insurance_withdrawal_collections/Index.js";
import "../insurance_withdrawal_collections/Show.js";
import "../monthly_closing_collections/Index.js";
import "../monthly_closing_collections/Show.js";
import "../AccountingBooksIndex.js";

const renderComponent = (Component, payload) => {
  ReactDOM.render(
    <Component {...payload} />,
    document.getElementById("react-root"),
  )
}

const routes = {
  "pages/index": (payload) => {
    renderComponent(DashboardMainUI, payload);
  },

  "members/index": (payload) => {
    MembersIndex.init();
  },

  "members/show": ({ memberId, authenticityToken }) => {
    MembersShow.init(memberId, authenticityToken);
  },

  "members/form": ({ id, memberTypes }) => {
    renderComponent(MembersFormDisplay, payload);
  },

  "pages/login": (payload) => {
    PagesLogin.init()
  },

  "savings_accounts/show": ({ id, authenticityToken }) => {
    SavingsAccountsShow.init({ id, authenticityToken });
  },

  "savings_accounts/time_deposit_withdrawal": ({ id, authenticityToken }) => {
    SavingsAccountsShowWithdrawalRequest.init({ id, authenticityToken });
  },

  "members/survey_answer_form": (payload) => {
    renderComponent(SurveyAnswerUIDisplay, payload);
  },

  "members/survey_answer": ({ id, memberId, authenticityToken }) => {
    SurveyAnswer.init({ id, memberId, authenticityToken });
  },

  "loans/show": ({ loanId, memberId, authenticityToken }) => {
    LoansShow.init({ loanId, authenticityToken });
    renderComponent(LoanAccountingEntryComponent, { id: loanId, memberId: memberId, authenticityToken: authenticityToken });
  },

  "loans/form": (payload) => {
    renderComponent(LoanApplicationForm, payload);
  },

  "billings/index": ({ authenticityToken }) => {
    BillingsIndex.init({ authenticityToken });
  },

  "billings/show": ({ billingId, authenticityToken }) => {
    BillingsShow.init({ billingId, authenticityToken });
    renderComponent(BillingUIComponent, { id: billingId, authenticityToken: authenticityToken });
  },

  "membership_payment_collections/index": ({ authenticityToken }) => {
    MembershipPaymentCollectionsIndex.init({ authenticityToken });
  },

  "membership_payment_collections/show": ({ membershipPaymentCollectionId, authenticityToken }) => {
    renderComponent(MembershipPaymentCollectionUIComponent, { id: membershipPaymentCollectionId, authenticityToken: authenticityToken });
  },

  "deposit_collections/index": ({ authenticityToken }) => {
    DepositCollectionsIndex.init({ authenticityToken: authenticityToken });
  },

  "deposit_collections/show": ({ depositCollectionId, centers, authenticityToken }) => {
    DepositCollectionsShow.init({ depositCollectionId, authenticityToken });
    renderComponent(DepositCollectionUIComponent, { authenticityToken: authenticityToken, id: depositCollectionId, centers: centers });
  },

  "deposit_collections/index": ({ authenticityToken }) => {
    TimeDepositCollectionsIndex.init({ authenticityToken });
  },

  "deposit_collections/show": ({ timeDepositCollectionId, authenticityToken }) => {
    TimeDepositCollectionsShow.init({ timeDepositCollectionId, authenticityToken });
    renderComponent(TimeDepositCollectionUIComponent, { id: timeDepositCollectionId, authenticityToken: authenticityToken });
  },

  "withdrawal_collections/index": ({ authenticityToken }) => {
    WithdrawalCollectionsShow.init({ authenticityToken });
  },

  "withdrawal_collections/show": ({ withdrawalCollectionId, authenticityToken }) => {
    WithdrawalCollectionsShow.init({ withdrawalCollectionId, authenticityToken });
    renderComponent(WithdrawalCollectionUIComponent, { id: withdrawalCollectionId, authenticityToken: authenticityToken });
  },

  "savings_insurance_transfer_collections/index": (payload) => {
    SavingsInsuranceTransferCollectionsIndex.init({ authenticityToken });
  },

  "savings_insurance_transfer_collections/show": (payload) => {
    SavingsInsuranceTransferCollectionsShow.init(payload);
  },

  "insurance_fund_transfer_collections/index": (payload) => {
    InsuranceFundTransferCollectionsIndex.init(payload);
  },

  "insurance_fund_transfer_collections/show": ({ id, centers, authenticityToken }) => {
    InsuranceFundTransferCollectionsShow.init({ authenticityToken: authenticityToken, insuranceFundTransferCollectionId: id });
    renderComponent(InsuranceFundTransferCollectionUIComponent, payload);
  },

  "insurance_withdrawal_collections/index": (payload) => {
    InsuranceWithdrawalCollectionsIndex.init(payload);
  },

  "insurance_withdrawal_collections/show": ({ id, authenticityToken }) => {
    InsuranceWithdrawalCollectionsShow.init({ insuranceWithdrawalCollectionId: id, authenticityToken: authenticityToken });
    renderComponent(InsuranceWithdrawalCollectionUIComponent, payload);
  },

  "monthly_closing_collections/index": (payload) => {
    MonthlyClosingCollectionsIndex.init(payload);
  },

  "monthly_closing_collections/show": (payload) => {
    MonthlyClosingCollectionsShow.init(payload);
    renderComponent(MonthlyClosingCollectionsShowUI, payload);
  },

  "insurance_accounts/show": ({ id }) => {
    renderComponent(InsuranceStatusComponent, { memberAccountId: id });
  },

  "accounting/crb":  (payload) => { AccountingBooksIndex.init(payload); },
  "accounting/cdb":  (payload) => { AccountingBooksIndex.init(payload); },
  "accounting/jvb":  (payload) => { AccountingBooksIndex.init(payload); },
  "accounting/misc": (payload) => { AccountingBooksIndex.init(payload); },
}

document.addEventListener("DOMContentLoaded", () => {
  const { controller_action, payload } = JSON.parse($("meta[name='parameters']").attr('content'));
  const authenticityToken = $("meta[name='csrf-token']").attr('content');
  payload.authenticityToken = authenticityToken;

  routes[controller_action](payload);
});
