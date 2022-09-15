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
            <small className="text-muted">
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
            </tbody>
          </table>
        </div>
      </div>
    </>
  )
}
