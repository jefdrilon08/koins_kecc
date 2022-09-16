import React, { useState, useEffect } from "react";
import ErrorList from '../ErrorList';
import axios from 'axios';
import { numberAsPercent, numberWithCommas } from "../utils/helpers";

export default function BranchPsrRecordsShow(props) {
  const [data]  = useState(props.data);
  const [token] = useState(props.token);

  return (
    <>
      <div className="card">
        <div className="card-body">
          <h4>
            {data.branch}
            <small className="text-muted ms-2">
              {data.closing_date}
            </small>
          </h4>

          <table className="table table-sm table-bordered">
            <tbody>
              <tr>
                <th>
                  Total Number of Active Members
                </th>
                <th className="text-center">
                  {data.data.active_total}
                </th>
              </tr>
              <tr>
                <th>
                  Female
                </th>
                <td className="text-center">
                  {data.data.active_female}
                </td>
              </tr>
              <tr>
                <th>
                  Male
                </th>
                <td className="text-center">
                  {data.data.active_male}
                </td>
              </tr>
              <tr>
                <th>
                  Pure Savers
                </th>
                <td className="text-center">
                  {data.data.pure_savers}
                </td>
              </tr>
              <tr>
                <th>
                  Active Borrowers
                </th>
                <td className="text-center">
                  {data.data.active_borrowers}
                </td>
              </tr>
              <tr>
                <th>
                  Admitted Members
                </th>
                <td className="text-center">
                  {data.data.admitted}
                </td>
              </tr>
              <tr>
                <th>
                  Resigned
                </th>
                <td className="text-center">
                  {data.data.resigned}
                </td>
              </tr>
              <tr>
                <th>
                  Percentage of Savers
                </th>
                <td className="text-center">
                  {numberAsPercent(data.data.pure_savers / data.data.active_total)}
                </td>
              </tr>
              <tr>
                <th>
                  Percentage of Borrowers
                </th>
                <td className="text-center">
                  {numberAsPercent(data.data.active_borrowers / data.data.active_total)}
                </td>
              </tr>
              <tr>
                <th>
                  Total Number of Active Loans
                </th>
                <th className="text-center">
                  {data.data.total_active_loans}
                </th>
              </tr>
              {data.data.loans.map((o) => {
                return (
                  <tr key={`loan-count-${o.loan_product.id}`}>
                    <th>
                      {o.loan_product.name}
                    </th>
                    <td className="text-center">
                      {o.count}
                    </td>
                  </tr>
                )
              })}
              <tr>
                <th>
                  Outstanding Loans
                </th>
                <th className="text-end">
                  {numberWithCommas(data.data.total_overall_principal_balance)} 
                </th>
              </tr>
              {data.data.loans.map((o) => {
                return (
                  <tr key={`loan-portfolio-${o.loan_product.id}`}>
                    <th>
                      {o.loan_product.name}
                    </th>
                    <td className="text-end">
                      {numberWithCommas(o.overall_principal_balance)}
                    </td>
                  </tr>
                )
              })}
              <tr>
                <th>
                  Loans Disbursed for the Month
                </th>
                <th className="text-center">
                  {data.data.total_num_disbursed}
                </th>
              </tr>
              {data.data.loans.map((o) => {
                return (
                  <tr key={`loan-num-disbursed-${o.loan_product.id}`}>
                    <th>
                      {o.loan_product.name}
                    </th>
                    <td className="text-center">
                      {o.num_disbursed}
                    </td>
                  </tr>
                )
              })}
              <tr>
                <th>
                  Amount Disbursed As Of
                </th>
                <th className="text-end">
                  {numberWithCommas(data.data.total_amount_disbursed)} 
                </th>
              </tr>
              {data.data.loans.map((o) => {
                return (
                  <tr key={`loan-amount-disbursed-${o.loan_product.id}`}>
                    <th>
                      {o.loan_product.name}
                    </th>
                    <td className="text-end">
                      {numberWithCommas(o.amount_disbursed)}
                    </td>
                  </tr>
                )
              })}
              <tr>
                <th>
                  Gross Income
                </th>
                <th className="text-end">
                  {numberWithCommas(data.data.gross_income)}
                </th>
              </tr>
              <tr>
                <th>
                  Operating Expense
                </th>
                <th className="text-end">
                  {numberWithCommas(data.data.operating_expense)}
                </th>
              </tr>
              <tr>
                <th>
                  Net Income Before ADmin Expense
                </th>
                <th className="text-end">
                  {numberWithCommas(data.data.net_income_before_admin_expense)}
                </th>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </>
  )
}
