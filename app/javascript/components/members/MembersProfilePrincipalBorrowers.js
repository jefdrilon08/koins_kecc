// MembersProfilePrincipalBorrowers.js
import React from "react";

export default function MembersProfilePrincipalBorrowers({ records = [] }) {
  const hasRows = Array.isArray(records) && records.length > 0;
  if (!hasRows) return <p>No principal borrower records found.</p>;

  return (
    <table className="table table-sm table-bordered">
      <thead>
        <tr>
          <th>Member</th>
          <th>PN Number</th>
          <th>Loan Product</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        {records.map((pb, idx) => (
          <tr key={`${pb.loan_id || pb.member_id || idx}`}>
            <td>{pb.member_name || "—"}</td>
            <td>{pb.loan_pn_number || "—"}</td>
            <td>
              {pb.loan_id ? (
                <a
                  href={`/loans/${pb.loan_id}`}
                  style={{ textDecoration: "none", cursor: "pointer" }}
                >
                  {pb.loan_product_name || "—"}
                </a>
              ) : (
                pb.loan_product_name || "—"
              )}
            </td>
            <td>{pb.loan_status || "—"}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
