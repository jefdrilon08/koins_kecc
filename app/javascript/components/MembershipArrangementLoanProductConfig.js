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
                    Maintaining Balances
                  </h5>
                  {
                    obj.maintaining_balances.map((mbObj, mbIndex) => {
                      return (
                        <div className="card" key={"mb-" + mbIndex}> 
                          <div className="card-body">
                            <div className="form-group">
                              <label>
                                Account Type
                              </label>
                              <select 
                                className="form-control"
                                value={mbObj.account_type}
                                onChange={(event) =>  props.updateMaintainingBalanceAccountType(index, mbIndex, event.target.value)}
                              >
                                <option value="SAVINGS">SAVINGS</option>
                                <option value="INSURANCE">INSURANCE</option>
                              </select>
                            </div>
                            <div className="form-group">
                              <label>
                                Account Subtype
                              </label>
                              <input
                                className="form-control"
                                value={mbObj.account_subtype}
                                onChange={(event) => props.updateMaintainingBalanceAccountSubtype(index, mbIndex, event.target.value)}
                              />
                            </div>
                            <div className="form-group">
                              <label>
                                Percentage
                              </label>
                              <input
                                className="form-control"
                                value={mbObj.percentage}
                                onChange={(event) => props.updateMaintainingBalancePercentage(index, mbIndex, event.target.value)}
                              />
                            </div>
                            <div className="form-group">
                              <label>
                                Threshold
                              </label>
                              <input
                                className="form-control"
                                value={mbObj.threshold}
                                onChange={(event) => props.updateMaintainingBalanceThreshold(index, mbIndex, event.target.value)}
                              />
                            </div>
                            <button
                              className="btn btn-danger btn-block"
                              onClick={() => props.removeMaintainingBalance(index, mbIndex)}
                            >
                              Remove
                            </button>
                          </div>
                        </div>
                      )
                    })
                  }
                  <button
                    className="btn btn-primary btn-sm"
                    onClick={() => props.addMaintainingBalance(index)}
                  >
                    Add Maintaining Balance Config
                  </button>

                  <hr/>

                  <h5>
                    Midas Configuration
                  </h5>

                  <div
                    className="card"
                  >
                    <div className="card-body">
                      <div className="form-group">
                        <label>
                          Contract Type
                        </label>
                        <input
                          className="form-control"
                          value={obj.midas.contract_type}
                          onChange={(event) => props.updateMidasContractType(index, event.target.value)}
                        />
                      </div>
                      <div className="form-group">
                        <label>
                          Contract Phase
                        </label>
                        <input
                          className="form-control"
                          value={obj.midas.contract_phase}
                          onChange={(event) => props.updateMidasContractPhase(index, event.target.value)}
                        />
                      </div>
                      <div className="form-group">
                        <label>
                          Transaction Type
                        </label>
                        <input
                          className="form-control"
                          value={obj.midas.transaction_type}
                          onChange={(event) => props.updateMidasTransactionType(index, event.target.value)}
                        />
                      </div>
                      <div className="form-group">
                        <label>
                          Loan Purpose
                        </label>
                        <input
                          className="form-control"
                          value={obj.midas.loan_purpose}
                          onChange={(event) => props.updateMidasLoanPurpose(index, event.target.value)}
                        />
                      </div>
                    </div>
                  </div>

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
