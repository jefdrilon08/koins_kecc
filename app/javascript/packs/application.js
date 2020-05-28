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

// Better router
document.addEventListener("DOMContentLoaded", () => {
  const { controller_action, payload } = JSON.parse($("meta[name='parameters']").attr('content'))
  const authenticityToken = $("meta[name='csrf-token']").attr('content')
  payload.authenticityToken = authenticityToken

  if (controller_action === "pages/index") {
    renderComponent(MainUI, payload);
  }

  if (controller_action == "members/index") {
    MembersIndex.init();
  }

  if (controller_action == "members/show") {
    const { memberId } = payload;
    MembersShow.init(memberId, authenticityToken);
  }

  if (controller_action == "members/form") {
    const { id, memberTypes } = payload;

    renderComponent(MembersFormDisplay, payload);
  }

  if (controller_action === "pages/login") {
    PagesLogin.init()
  }

  if (controller_action === "savings_accounts/show") {
    const { id } = payload;
    SavingsAccountsShow.init({ id, authenticityToken });
  }

  if (controller_action == "savings_accounts/time_deposit_withdrawal") {
    const { id } = payload;
    SavingsAccountsShowWithdrawalRequest.init({ id, authenticityToken });
  }

  if (controller_action == "members/survey_answer_form") {
    renderComponent(SurveyAnswerUIDisplay, payload);
  }

  if (controller_action == "members/survey_answer") {
    const { id, memberId } = payload;

    SurveyAnswer.init({ id, memberId, authenticityToken });
  }

  if (controller_action == "loans/show") {
    const { loanId, memberId }  = payload;

    LoansShow.init({ loanId, authenticityToken });

    renderComponent(LoanAccountingEntryComponent, { id: loanId, memberId: memberId, authenticityToken: authenticityToken });
  }

  if (controller_action == "loans/form") {
    renderComponent(LoanApplicationForm, payload); 
  }

  if (controller_action == "billings/index") {
    BillingsIndex.init({ authenticityToken });
  }
  
  if (controller_action == "billings/show") {
    const { billingId } = payload;

    BillingsShow.init({ billingId, authenticityToken });

    renderComponent(BillingUIComponent, { id: billingId, authenticityToken: authenticityToken });
  }

  if (controller_action == "membership_payment_collections/index") {
    MembershipPaymentCollectionsIndex.init({ authenticityToken: authenticityToken });
  }

  if (controller_action == "membership_payment_collections/show") {
    const { membershipPaymentCollectionId } = payload;

    MembershipPaymentCollectionsShow.init({ membershipPaymentCollectionId, authenticityToken });

    renderComponent(MembershipPaymentCollectionUIComponent, { id: membershipPaymentCollectionId, authenticityToken: authenticityToken });
  }

  if (controller_action == "deposit_collections/index") {
    DepositCollectionsIndex.init({ authenticityToken: authenticityToken });
  }

  if (controller_action == "deposit_collections/show") {
    const { depositCollectionId, centers } = payload;

    DepositCollectionsShow.init({ depositCollectionId, authenticityToken });

    renderComponent(DepositCollectionUIComponent, { authenticityToken: authenticityToken, id: depositCollectionId, centers: centers });
  }

  if (controller_action == "deposit_collections/index") {
    TimeDepositCollectionsIndex.init({ authenticityToken });
  }

  if (controller_action == "deposit_collections/show") {
    const { timeDepositCollectionId } = payload;

    TimeDepositCollectionsShow.init({ timeDepositCollectionId, authenticityToken });

    renderComponent(TimeDepositCollectionUIComponent, { id: timeDepositCollectionId, authenticityToken: authenticityToken });
  }

  if (controller_action == "withdrawal_collections/index") {
    WithdrawalCollectionsShow.init({ authenticityToken });
  }

  if (controller_action == "withdrawal_collections/show") {
    const { withdrawalCollectionId }  = payload;

    WithdrawalCollectionsShow.init({ withdrawalCollectionId, authenticityToken });

    renderComponent(WithdrawalCollectionUIComponent, { id: withdrawalCollectionId, authenticityToken: authenticityToken });
  }

  if (controller_action == "savings_insurance_transfer_collections/index") {
    SavingsInsuranceTransferCollectionsIndex.init({ authenticityToken });
  }

  if (controller_action == "savings_insurance_transfer_collections/show") {
    SavingsInsuranceTransferCollectionsShow.init(payload);
  }

  if (controller_action == "insurance_fund_transfer_collections/index") {
    InsuranceFundTransferCollectionsIndex.init(payload);
  }

  if (controller_action == "insurance_fund_transfer_collections/show") {
    const { id, centers } = payload;

    InsuranceFundTransferCollectionsShow.init({ authenticityToken: authenticityToken, insuranceFundTransferCollectionId: id });

    renderComponent(InsuranceFundTransferCollectionUIComponent, payload);
  }

  if (controller_action == "insurance_withdrawal_collections/index") {
    InsuranceWithdrawalCollectionsIndex.init(payload);
  }

  if (controller_action == "insurance_withdrawal_collections/show") {
    const { id } = payload;

    InsuranceWithdrawalCollectionsShow.init({ insuranceWithdrawalCollectionId: id, authenticityToken: authenticityToken });

    renderComponent(InsuranceWithdrawalCollectionUIComponent, payload);
  }

  if (controller_action == "monthly_closing_collections/index") {
    MonthlyClosingCollectionsIndex.init(payload);
  }

  if (controller_action == "monthly_closing_collections/show") {
    MonthlyClosingCollectionsShow.init(payload);

    renderComponent(MonthlyClosingCollectionsShowUI, payload);
  }

  if (controller_action == "insurance_accounts/show") {
    const { id } = payload;

    renderComponent(InsuranceStatusComponent, { memberAccountId: id });
  }

  if (controller_action == "accounting/crb" || controller_action == "accounting/cdb" || controller_action == "accounting/jvb" || controller_action == "accounting/misc") {
    AccountingBooksIndex.init(payload); 
  }
});
