import React, { useState } from 'react';
import Toggle from 'react-toggle';

import MembershipArrangementLoanProductConfig from "./MembershipArrangementLoanProductConfig";

import { buildLoanProductConfigObject } from "./utils/helpers";

function MembershipArrangementShow(props) {
  const [id]                      = useState(props.id);
  const [data, setData]           = useState(props.data);
  const [accounting_codes]        = useState(props.accounting_codes);
  const [loan_products]           = useState(props.loan_products);
  const [isLoading, setIsLoading] = useState(false);

  function handleSave() {
    setIsLoading(true);

    const payload = {
      id: id,
      data: JSON.stringify(data),
      authenticity_token: props.authenticityToken
    }

    $.ajax({
      url: "/api/v1/administration/membership_arrangements/update_data",
      method: 'POST',
      data: payload,
      success: function(response) {
        console.log("Successfully updated data");
        alert("Successfully updated data!");

        setData(data);
        setIsLoading(false);
      },
      error: function(response) {
        console.log(response);
        alert("Error in updating data");
        setIsLoading(false);
      }
    })
  }

  function removeLoanProductConfig(index) {
    data.loan_products.splice(index, 1);

    setData({...data});
  }

  function updateDefaultAmount(index, amount) {
    data.loan_products[index].default_amount = amount;

    setData({...data});
  }

  function updateLoanProductId(index, id) {
    data.loan_products[index].id = id;

    setData({...data});
  }

  function updateReceivableAccountingCode(index, id) {
    data.loan_products[index].receivable_accounting_code_id = id;

    setData({...data});
  }

  function updateInterestReceivableAccountingCode(index, id) {
    data.loan_products[index].interest_receivable_accounting_code_id = id;

    setData({...data});
  }

  function handleAddLoanProductConfigClicked() {
    const configObject = buildLoanProductConfigObject();

    if(!data.loan_products) {
      data.loan_products = [];
    }
    
    data.loan_products.push(configObject);

    setData({...data});
  }

  function handleUseCoMakerOneChanged(event) {
    data.use_co_maker_one = event.target.checked;

    setData({...data});
  }

  function handleUseCoMakerTwoChanged(event) {
    data.use_co_maker_two = event.target.checked;

    setData({...data});
  }

  function handleUseCoMakerThreeChanged(event) {
    data.use_co_maker_three = event.target.checked;

    setData({...data});
  }

  return (
    <div className="">
      <h4>
        Co-maker Settings for Loan Application
      </h4>
      <div className="row">
        <div className="col">
          <table className="table table-sm table-bordered">
            <thead>
              <tr>
                <th>
                  Co-maker 1 (Kasama sa sentro)
                </th>
                <th>
                  Co-maker 2 (Kamag-anak)
                </th>
                <th>
                  Co-maker 3 (Hindi kamag-anak / Kapit-bahay)
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                  <Toggle
                    defaultChecked={data.use_co_maker_one === 'true'}
                    onChange={handleUseCoMakerOneChanged}
                    className="btn"
                  />
                </td>
                <td>
                  <Toggle
                    defaultChecked={data.use_co_maker_two === 'true'}
                    onChange={handleUseCoMakerTwoChanged}
                    className="btn"
                  />
                </td>
                <td>
                  <Toggle
                    defaultChecked={data.use_co_maker_three === 'true'}
                    onChange={handleUseCoMakerThreeChanged}
                    className="btn"
                  />
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <h4>
        Loan Product Configuration
      </h4>
      <hr/>
      <button
        onClick={() => handleAddLoanProductConfigClicked()}
        className="btn btn-primary"
      >
        Add Loan Product Config
      </button>
      <hr/>
      <MembershipArrangementLoanProductConfig
        loan_products={data.loan_products}
        loanProductOptions={loan_products}
        accountingCodeOptions={accounting_codes}
        removeLoanProductConfig={removeLoanProductConfig}
        updateLoanProductId={updateLoanProductId}
        updateReceivableAccountingCode={updateReceivableAccountingCode}
        updateInterestReceivableAccountingCode={updateInterestReceivableAccountingCode}
        updateDefaultAmount={updateDefaultAmount}
        isLoading={isLoading}
      />
      <hr/>
      <button
        className="btn btn-success btn-block"
        onClick={() => handleSave()}
      >
        <span
          className="fa fa-check"
        >
        </span>
        Save
      </button>
    </div>
  )
}

export default MembershipArrangementShow;
