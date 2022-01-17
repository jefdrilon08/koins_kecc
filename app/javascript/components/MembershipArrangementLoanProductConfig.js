import React, { useState } from 'react';
import Select from 'react-select';

function MembershipArrangementLoanProductConfig(props) { 
  let optionsLoanProducts = props.loanProductOptions.map((o) => {
    return {
      value: o.id,
      label: o.name
    }
  });

  let optionsAccountingCodes = props.accountingCodeOptions.map((o) => {
    return {
      value: o.id,
      label: o.name
    }
  });

  if(props.loan_products) { 
    return (
      <div>
        {
          props.loan_products.map((obj, index) => {
            return (
              <div 
                key={'loan-product-' + index}
                className="card"
              >
                <div className="card-body">
                  <div className="form-group">
                    <label>
                      Loan Product
                    </label>
                    <Select
                      options={optionsLoanProducts}
                      value={obj.id}
                      onSelect={(event) => props.updateLoanProductId(index, event.target.value)}
                      isDisabled={props.isLoading}
                    />
                  </div>
                  <div className="form-group">
                    <label>
                      Receivable Accounting Code
                    </label>
                    <Select
                      options={optionsAccountingCodes}
                      value={obj.id}
                      onSelect={(event) => props.updateReceivableAccountingCode(index, event.target.value)}
                      isDisabled={props.isLoading}
                    />
                  </div>
                  <div className="form-group">
                    <label>
                      Interest Receivable Accounting Code
                    </label>
                    <Select
                      options={optionsAccountingCodes}
                      value={obj.id}
                      onSelect={(event) => props.updateInterestReceivableAccountingCode(index, event.target.value)}
                      isDisabled={props.isLoading}
                    />
                  </div>
                  <div className="form-group">
                    <label>
                      Default Amount
                    </label>
                    <input
                      value={obj.default_amount}
                      onChange={(event) => props.updateDefaultAmount(index, event.target.value)}
                      disabled={props.isLoading}
                      className="form-control"
                    />
                  </div>
                  
                  <h5>
                    Maintaining Balance Configuration
                  </h5>
                  {
                    obj.maintaining_balances.map((mbObj, mbIndex) => {
                      return (
                        <div className="card" key={"mb-" + mbIndex}> 
                          <div className="card-body">
                            <div className="form-group">
                              <label>
                              </label>
                            </div>
                          </div>
                          <hr/>
                          <button
                            className="btn btn-danger btn-block"
                          >
                            Remove
                          </button>
                        </div>
                      )
                    })
                  }

                  <hr/>
                  <button
                    className="btn btn-danger"
                    onClick={() => props.removeLoanProductConfig(index)}
                  >
                    Remove
                  </button>
                </div>
              </div>
            )
          })
        }
      </div>
    )
  } else {
    return (
      <p>
        No loan product configurations
      </p>
    )
  }
}

export default MembershipArrangementLoanProductConfig;
