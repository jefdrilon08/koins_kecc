import 'core-js/stable'
import 'regenerator-runtime/runtime'
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

require("@rails/ujs").start()
require("@rails/activestorage").start()

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
    renderComponent(DashboardMainUI, payload)
  }

  if (controller_action === "pages/login") {
    PagesLogin.init()
  }

  if (controller_action === "savings_accounts/show") {
    const { id } = payload
    SavingsAccountsShow.init({ id, authenticityToken })
  }

  if (controller_action == "savings_accounts/time_deposit_withdrawal") {
    const { id } = payload
    SavingsAccountsShowWithdrawalRequest.init({ id, authenticityToken })
  }
})

// Router
$(document).ready(function() {
  var authenticityToken = $("meta[name='csrf-token']").attr('content');

  var $parameters = $("#parameters");
  var controller  = $parameters.data("controller");
  var action      = $parameters.data("action");

  console.log("Controller: " + controller + " Action: " + action);

  if(controller == "members") {
    if(action == "index") {
      MembersIndex.init();
    } else if(action == "show") {
      var memberId  = $parameters.data("member-id");

      MembersShow.init(memberId, authenticityToken);
    } else if(action == "form") {
      var id          = $parameters.data("id");
      var memberTypes = $parameters.data("member-types");

      ReactDOM.render(
        <MembersFormDisplay
          authenticityToken={authenticityToken}
          memberTypes={memberTypes}
          id={id}
        />,
        document.getElementById('content')
      );
    } else if(action == "survey_answer_form") {
      var id        = $parameters.data("id");
      var memberId  = $parameters.data("member-id");

      ReactDOM.render(
        <SurveyAnswerUIDisplay
          authenticityToken={authenticityToken}
          memberId={memberId}
          id={id}
        />,
        document.getElementById('survey-answer-content')
      );
    } else if(action == "survey_answer") {
      var id        = $parameters.data("id");
      var memberId  = $parameters.data("member-id");

      SurveyAnswer.init({
        id: id,
        memberId: memberId,
        authenticityToken: authenticityToken
      });
    }
  } else if(controller == "loans") {
    if(action == "show") {
      var loanId    = $parameters.data("id");
      var memberId  = $parameters.data("member-id");

      LoansShow.init({
        loanId: loanId,
        authenticityToken: authenticityToken
      });

      ReactDOM.render(
        <LoanAccountingEntryComponent
          authenticityToken={authenticityToken}
          id={loanId}
          memberId={memberId}
        />,
        document.getElementById('loan-accounting-entry-content')
      );
    } else if(action == "form") {
      var id        = $parameters.data("id");
      var memberId  = $parameters.data("member-id");
      var banks     = $parameters.data("banks");

      ReactDOM.render(
        <LoanApplicationForm
          authenticityToken={authenticityToken}
          id={id}
          memberId={memberId}
          banks={banks}
        />,
        document.getElementById('loan-application-content')
      );
    }
  } else if(controller == "billings") {
    if(action == "index") {
      BillingsIndex.init({
        authenticityToken: authenticityToken
      });
    } else if(action == "show") {
      var billingId = $parameters.data("id");

      BillingsShow.init({
        billingId: billingId,
        authenticityToken: authenticityToken
      });

      ReactDOM.render(
        <BillingUIComponent
          authenticityToken={authenticityToken}
          id={billingId}
        />,
        document.getElementById('billing-content')
      );
    }
  } else if(controller == "membership_payment_collections") {
    if(action == "index") {
      MembershipPaymentCollectionsIndex.init({
        authenticityToken: authenticityToken
      });
    } else if(action == "show") {
      var membershipPaymentCollectionId = $parameters.data('id');

      MembershipPaymentCollectionsShow.init({
        membershipPaymentCollectionId: membershipPaymentCollectionId,
        authenticityToken: authenticityToken
      });

      ReactDOM.render(
        <MembershipPaymentCollectionUIComponent
          authenticityToken={authenticityToken}
          id={membershipPaymentCollectionId}
        />,
        document.getElementById('membership-payment-collection-content')
      );
    }
  } else if(controller == "deposit_collections") {
    if(action == "index") {
      DepositCollectionsIndex.init({
        authenticityToken: authenticityToken
      });
    } else if(action == "show") {
      var depositCollectionId = $parameters.data('id');
      var centers             = $parameters.data('centers');

      DepositCollectionsShow.init({
        depositCollectionId: depositCollectionId, 
        authenticityToken: authenticityToken
      });

      ReactDOM.render(
        <DepositCollectionUIComponent
          authenticityToken={authenticityToken}
          id={depositCollectionId}
          centers={centers}
        />,
        document.getElementById('deposit-collection-content')
      );
    }
  } else if(controller == "time_deposit_collections") {
    if(action == "index") {
      TimeDepositCollectionsIndex.init({
        authenticityToken: authenticityToken
      });
    } else if(action == "show") {
      var timeDepositCollectionId = $parameters.data('id');

      TimeDepositCollectionsShow.init({
        timeDepositCollectionId: depositCollectionId, 
        authenticityToken: authenticityToken
      });

      ReactDOM.render(
        <TimeDepositCollectionUIComponent
          authenticityToken={authenticityToken}
          id={timeDepositCollectionId}
        />,
        document.getElementById('time-deposit-collection-content')
      );
    }
  } else if(controller == "withdrawal_collections") {
    if(action == "index") {
      WithdrawalCollectionsIndex.init({
        authenticityToken: authenticityToken
      });
    } else if(action == "show") {
      var withdrawalCollectionId = $parameters.data('id');

      WithdrawalCollectionsShow.init({
        withdrawalCollectionId: withdrawalCollectionId,
        authenticityToken: authenticityToken
      });

      ReactDOM.render(
        <WithdrawalCollectionUIComponent
          authenticityToken={authenticityToken}
          id={withdrawalCollectionId}
        />,
        document.getElementById('withdrawal-collection-content')
      );
    }
  } else if(controller == "savings_insurance_transfer_collections") {
    if(action == "index") {
      SavingsInsuranceTransferCollectionsIndex.init({
        authenticityToken: authenticityToken
      });
    } else if(action == "show") {
      var id = $parameters.data('id');

      SavingsInsuranceTransferCollectionsShow.init({
        id: id,
        authenticityToken: authenticityToken
      });
    }
  } else if(controller == "insurance_fund_transfer_collections") {
    if(action == "index") {
      InsuranceFundTransferCollectionsIndex.init({
        authenticityToken: authenticityToken
      });
    } else if(action == "show") {
      var id      = $parameters.data('id');
      var centers = $parameters.data("centers");

      InsuranceFundTransferCollectionsShow.init({
        authenticityToken: authenticityToken,
        insuranceFundTransferCollectionId: id
      });

      ReactDOM.render(
        <InsuranceFundTransferCollectionUIComponent
          authenticityToken={authenticityToken}
          centers={centers}
          id={id}
        />,
        document.getElementById('insurance-fund-transfer-collection-content')
      );
    }
  } else if(controller == "insurance_withdrawal_collections") {
    if(action == "index") {
      InsuranceWithdrawalCollectionsIndex.init({
        authenticityToken: authenticityToken
      });
    } else if(action == "show") {
      var id  = $parameters.data('id');

      InsuranceWithdrawalCollectionsShow.init({
        insuranceWithdrawalCollectionId: id,
        authenticityToken: authenticityToken
      });

      ReactDOM.render(
        <InsuranceWithdrawalCollectionUIComponent
          authenticityToken={authenticityToken}
          id={id}
        />,
        document.getElementById('insurance-withdrawal-collection-content')
      );
    }
  } else if(controller == "monthly_closing_collections") {
    if(action == "index") {
      MonthlyClosingCollectionsIndex.init({
        authenticityToken: authenticityToken
      });
    } else if(action == "show") {
      var id  = $parameters.data("id");

      MonthlyClosingCollectionsShow.init({
        id: id,
        authenticityToken: authenticityToken
      });

      ReactDOM.render(
        <MonthlyClosingCollectionsShowUI
          authenticityToken={authenticityToken}
          id={id}
        />,
        document.getElementById('content')
      );
    }
  } if(controller == "insurance_accounts") {
    if(action == "show") {
      var id  = $parameters.data("member-account-id");

      ReactDOM.render(
        <InsuranceStatusComponent
          memberAccountId={id}
        />,
        document.getElementById("content-status")
      );
    }
  }
});
