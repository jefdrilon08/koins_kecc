import React, { useState, useEffect } from "react";

export default function AdministrationBranchesShow(props) {
  const [user, setUser] = useState(props.user);
  const [data, setData] = useState(props.data);

  return (
    <>
      <h4>
        {data.name}
      </h4>
      <hr/>
      <table className="table table-bordered table-sm">
        <tbody>
          <tr>
            <th>
              Color
            </th>
            <th style={{ backgroundColor: `${data.color}`}}>
            </th>
          </tr>
          <tr>
            <th>
              OR Prefix
            </th>
            <td>
              {data.or_prefix}
            </td>
          </tr>
          <tr>
            <th>
              OR Current Max
            </th>
            <td>
              {data.or_current_max}
            </td>
          </tr>
          <tr>
            <th>
              OR Counter
            </th>
            <td>
              {data.or_counter}
            </td>
          </tr>
          <tr>
            <th>
              AR Prefix
            </th>
            <td>
              {data.ar_prefix}
            </td>
          </tr>
          <tr>
            <th>
              AR Current Max
            </th>
            <td>
              {data.ar_current_max}
            </td>
          </tr>
          <tr>
            <th>
              AR Counter
            </th>
            <td>
              {data.ar_counter}
            </td>
          </tr>
        </tbody>
      </table>
      <hr/>
      <h5>
        Centers
      </h5>
      <hr/>
      <table className="table table-bordered table-sm">
        <thead>
          <tr>
            <th>
              Name
            </th>
            <th>
              SO
            </th>
            <th>
              Meeting Day
            </th>
            <th className="text-center">
              # Members
            </th>
          </tr>
        </thead>
        <tbody>
          {data.centers.map((center) => {
            return (
              <tr key={`center-${center.id}`}>
                <td>
                  <a href={`/administration/centers/${center.id}`}>
                    {center.name}
                  </a>
                </td>
                <td>
                  {center.user}
                </td>
                <td>
                  {center.meeting_day_display}
                </td>
                <td>
                  {center.member_count}
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </>
  )
}
