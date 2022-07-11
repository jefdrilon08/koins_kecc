import React, { useState, useEffect } from "react";

export default function MembersProfileLoans(props) {
  const [isLoading, setIsLoading] = useState(false);

  return (
    <>
      <h6>
        Active Loans &nbsp;
        <small className="text-muted">
          Entry Point Loan Cycle Count: {props.entryPointLoanCycleCount}
        </small>
      </h6>
      {(() => {
        if(props.activeLoans.length > 0) {
          return (
            <table className="table table-bordered table-hover table-sm">
              <thead>
                <tr>
                  <th>
                    PN Number
                  </th>
                  <th>
                    Loan Product
                  </th>
                  <th className="text-center">
                    Cycle
                  </th>
                  <th className="text-end">
                    Total Due
                  </th>
                  <th className="text-end">
                    Total Paid
                  </th>
                  <th className="text-end">
                    Total Balance
                  </th>
                </tr>
              </thead>
              <tbody>
                {props.activeLoans.map((o) => {
                  return (
                    <tr key={"active-loan-" + o.id}>
                      <td>
                        <a href={`/loans/${o.id}`}>
                          <strong>
                            {o.pn_number}
                          </strong>
                        </a>
                      </td>
                      <td className="text-muted">
                        {o.loan_product}
                      </td>
                      <td className="text-center">
                        {o.cycle}
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_dues}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_paid}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_balance}
                        </strong>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )
        } else {
          return (
            <p>
              No loans found.
            </p>
          )
        }
      })()}
      <button
        className="btn btn-primary"
        disabled={isLoading}
      >
        Restructure
      </button>

      <hr/>
      <h6>
        For Verification &nbsp;
        <small className="text-muted">
          Online
        </small>
      </h6>
      {(() => {
        if(props.forVerificationLoans.length > 0) {
          return (
            <table className="table table-bordered table-hover table-sm">
              <thead>
                <tr>
                  <th>
                    PN Number
                  </th>
                  <th>
                    Loan Product
                  </th>
                  <th className="text-center">
                    Cycle
                  </th>
                  <th className="text-end">
                    Total Due
                  </th>
                  <th className="text-end">
                    Total Paid
                  </th>
                  <th className="text-end">
                    Total Balance
                  </th>
                </tr>
              </thead>
              <tbody>
                {props.forVerificationLoans.map((o) => {
                  return (
                    <tr key={"forVerification-loan-" + o.id}>
                      <td>
                        <a href={`/loans/${o.id}`}>
                          <strong>
                            {o.pn_number}
                          </strong>
                        </a>
                      </td>
                      <td className="text-muted">
                        {o.loan_product}
                      </td>
                      <td className="text-center">
                        {o.cycle}
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_dues}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_paid}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_balance}
                        </strong>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )
        } else {
          return (
            <p>
              No loans found.
            </p>
          )
        }
      })()}

      <hr/>
      <h6>
        Verified &nbsp;
        <small className="text-muted">
          Online
        </small>
      </h6>
      {(() => {
        if(props.verifiedLoans.length > 0) {
          return (
            <table className="table table-bordered table-hover table-sm">
              <thead>
                <tr>
                  <th>
                    PN Number
                  </th>
                  <th>
                    Loan Product
                  </th>
                  <th className="text-center">
                    Cycle
                  </th>
                  <th className="text-end">
                    Total Due
                  </th>
                  <th className="text-end">
                    Total Paid
                  </th>
                  <th className="text-end">
                    Total Balance
                  </th>
                </tr>
              </thead>
              <tbody>
                {props.verifiedLoans.map((o) => {
                  return (
                    <tr key={"verified-loan-" + o.id}>
                      <td>
                        <a href={`/loans/${o.id}`}>
                          <strong>
                            {o.pn_number}
                          </strong>
                        </a>
                      </td>
                      <td className="text-muted">
                        {o.loan_product}
                      </td>
                      <td className="text-center">
                        {o.cycle}
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_dues}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_paid}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_balance}
                        </strong>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )
        } else {
          return (
            <p>
              No loans found.
            </p>
          )
        }
      })()}

      <hr/>
      <h6>
        In Process &nbsp;
        <small className="text-muted">
          Online
        </small>
      </h6>
      {(() => {
        if(props.inProcessLoans.length > 0) {
          return (
            <table className="table table-bordered table-hover table-sm">
              <thead>
                <tr>
                  <th>
                    PN Number
                  </th>
                  <th>
                    Loan Product
                  </th>
                  <th className="text-center">
                    Cycle
                  </th>
                  <th className="text-end">
                    Total Due
                  </th>
                  <th className="text-end">
                    Total Paid
                  </th>
                  <th className="text-end">
                    Total Balance
                  </th>
                </tr>
              </thead>
              <tbody>
                {props.inProcessLoans.map((o) => {
                  return (
                    <tr key={"inProcess-loan-" + o.id}>
                      <td>
                        <a href={`/loans/${o.id}`}>
                          <strong>
                            {o.pn_number}
                          </strong>
                        </a>
                      </td>
                      <td className="text-muted">
                        {o.loan_product}
                      </td>
                      <td className="text-center">
                        {o.cycle}
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_dues}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_paid}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_balance}
                        </strong>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )
        } else {
          return (
            <p>
              No loans found.
            </p>
          )
        }
      })()}

      <hr/>
      <h6>
        Pending
      </h6>
      {(() => {
        if(props.pendingLoans.length > 0) {
          return (
            <table className="table table-bordered table-hover table-sm">
              <thead>
                <tr>
                  <th>
                    PN Number
                  </th>
                  <th>
                    Loan Product
                  </th>
                  <th className="text-center">
                    Cycle
                  </th>
                  <th className="text-end">
                    Total Due
                  </th>
                  <th className="text-end">
                    Total Paid
                  </th>
                  <th className="text-end">
                    Total Balance
                  </th>
                </tr>
              </thead>
              <tbody>
                {props.pendingLoans.map((o) => {
                  return (
                    <tr key={"pending-loan-" + o.id}>
                      <td>
                        <a href={`/loans/${o.id}`}>
                          <strong>
                            {o.pn_number}
                          </strong>
                        </a>
                      </td>
                      <td className="text-muted">
                        {o.loan_product}
                      </td>
                      <td className="text-center">
                        {o.cycle}
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_dues}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_paid}
                        </strong>
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_balance}
                        </strong>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )
        } else {
          return (
            <p>
              No loans found.
            </p>
          )
        }
      })()}

      <hr/>
      <h6>
        Paid Loans
      </h6>
      {(() => {
        if(props.paidLoans.length > 0) {
          return (
            <table className="table table-bordered table-hover table-sm">
              <thead>
                <tr>
                  <th>
                    PN Number
                  </th>
                  <th>
                    Loan Product
                  </th>
                  <th className="text-center">
                    Cycle
                  </th>
                  <th className="text-end">
                    Total Paid
                  </th>
                </tr>
              </thead>
              <tbody>
                {props.paidLoans.map((o) => {
                  return (
                    <tr key={"paid-loan-" + o.id}>
                      <td>
                        <a href={`/loans/${o.id}`}>
                          <strong>
                            {o.pn_number}
                          </strong>
                        </a>
                      </td>
                      <td className="text-muted">
                        {o.loan_product}
                      </td>
                      <td className="text-center">
                        {o.cycle}
                      </td>
                      <td className="text-end">
                        <strong>
                          {o.total_paid}
                        </strong>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )
        } else {
          return (
            <p>
              No loans found.
            </p>
          )
        }
      })()}
    </>
  )
}
