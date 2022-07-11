import React, { useState, useEffect } from "react";

export default function MembersProfileInsurance(props) {
  return (
    <table className="table table-bordered table-hover table-sm">
      <thead>
        <tr>
          <th>
            Type
          </th>
          <th className="text-end">
            Balance
          </th>
        </tr>
      </thead>
      <tbody>
        {props.records.map((o) => {
          return (
            <tr key={`insurance-${o.id}`}>
              <td>
                <a href={`/insurance_accounts/${o.id}`}>
                  <strong>
                    {o.type}
                  </strong>
                </a>
              </td>
              <td className="text-end">
                {o.balance}
              </td>
            </tr>
          )
        })}
        <tr>
          <td>
            <strong>
              Total
            </strong>
          </td>
          <td className="text-end">
            <strong>
              {props.total}
            </strong>
          </td>
        </tr>
      </tbody>
    </table>
  )
}
