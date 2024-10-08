import React from 'react';
import {numberWithCommas, numberAsPercent} from '../../utils/helpers';
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.16.9/xlsx.full.min.js"></script>

export default RepaymentRatesView = (props) => {
  const renderDataRows = () => {
    var loans = props.data.records;
    var rows  = [];

    var totalPrincipal                = 0.00;
    var totalPrincipalPaid            = 0.00;
    var totalOverallPrincipalBalance  = 0.00;
    var totalInterest                 = 0.00;
    var totalInterestPaid             = 0.00;
    var totalOverallInterestBalance   = 0.00;
    var totalTotalPaid                = 0.00;
    var totalPrincipalDue             = 0.00;
    var totalTotalDue                 = 0.00;
    var totalTotalBalance             = 0.00;
    var totalPrincipalBalance         = 0.00;
    var totalOverallBalance           = 0.00;
    var totalRR                       = 0;
    var totalPrincipalRR              = 0;

    var totalPrincipalPaidDue = 0.00;
    var totalInterestPaidDue  = 0.00;
    var totalPaidDue          = 0.00;

    for(var i = 0; i < loans.length; i++) {
      var member      = loans[i].member;
      var center      = loans[i].center;
      var loanProduct = loans[i].loan_product;

      var backgroundColor = "#fff";
      
      if(loans[i].total_paid > loans[i].total_paid_due) {
        backgroundColor = "#e9ecfd";
      } else if(loans[i].principal_balance > 0) {
        backgroundColor = "#ffe1e1";
      }

      rows.push(
        <tr key={"rr-" + loans[i].id} style={{ backgroundColor: backgroundColor }}>
          <td className="text-center">
            {i + 1}
          </td>
          <td>
            <a href={"/loans/" + loans[i].id} target="_blank">
              <strong>
                {member.last_name}, {member.first_name} {member.middle_name}
                <br/>
                <small className="text-muted">
                  | {center.name} | {member.status}
                </small>
              </strong>
            </a>
          </td>
          <td>
            {loanProduct.name}
            <br/>
            <small className="text-muted">
              {loanProduct.loan_product_tagging_name}
            </small>
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].principal)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].principal_paid)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].overall_principal_balance)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].interest)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].interest_paid)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].overall_interest_balance)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].total_paid)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].overall_balance)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].principal_paid_due)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].principal_balance)}
          </td>
          <td className="text-end">
            {numberWithCommas(loans[i].principal_due)}
          </td>
          <td className="text-center">
            {numberAsPercent(loans[i].principal_rr)}
          </td>
        </tr>
      );

      totalPrincipal                += parseFloat(loans[i].principal);
      totalPrincipalPaid            += parseFloat(loans[i].principal_paid);
      totalPrincipalPaidDue         += parseFloat(loans[i].principal_paid_due);
      totalOverallPrincipalBalance  += parseFloat(loans[i].overall_principal_balance);
      totalInterest                 += parseFloat(loans[i].interest);
      totalInterestPaid             += parseFloat(loans[i].interest_paid);
      totalOverallInterestBalance   += parseFloat(loans[i].overall_interest_balance);
      totalTotalPaid                += parseFloat(loans[i].total_paid);
      totalPrincipalDue             += parseFloat(loans[i].principal_due);
      totalTotalDue                 += parseFloat(loans[i].total_due);
      totalTotalBalance             += parseFloat(loans[i].total_balance);
      totalPrincipalBalance         += parseFloat(loans[i].principal_balance);
      totalPaidDue                  += parseFloat(loans[i].total_paid_due);
    }

    totalOverallBalance = totalOverallPrincipalBalance + totalOverallInterestBalance;
    //totalRR = (totalTotalPaid / totalTotalDue);
    totalRR = (totalPaidDue / totalTotalDue);

    //totalRR = (totalPaidDue - totalTotalBalance) / totalPaidDue;
    //totalPrincipalRR  = (totalPrincipalPaidDue - totalPrincipalBalance) / totalPrincipalPaidDue;
    totalPrincipalRR  = (totalPrincipalPaidDue / totalPrincipalDue);

    if(totalPrincipalRR > 1)  {
      totalPrincipalRR = 1;
    }

    console.log("totalTotalPaid: " + totalTotalPaid);
    console.log("totalTotalDue: " + totalTotalDue);
    console.log("totalPaidDue: " + totalPaidDue);
    console.log("totalPrincipalPaidDue: " + totalPrincipalPaidDue);
    console.log("totalPrincipalBalance: " + totalPrincipalBalance);
    console.log("totalRR: " + totalRR);

    var backgroundColor = "#fff";

    rows.push(
      <tr key="rr-grand-total">
        <th className="text-center">
        </th>
        <th colSpan="2">
          <strong>
            Total ({loans.length})
          </strong>
        </th>
        <th className="text-end">
          {numberWithCommas(totalPrincipal)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalPrincipalPaid)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalOverallPrincipalBalance)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalInterest)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalInterestPaid)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalOverallInterestBalance)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalTotalPaid)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalOverallBalance)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalPrincipalPaidDue)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalPrincipalBalance)}
        </th>
        <th className="text-end">
          {numberWithCommas(totalPrincipalDue)}
        </th>
        <th className="text-center">
          {numberAsPercent(totalPrincipalRR)}
        </th>
        
      </tr>
    );

    return rows;
  }
  
  var numRecords  = 0;
  var numPastDue  = 0;
  var numAdvanced = 0;

  var loans = props.data.records;

  numRecords  = loans.length;

  for(var i = 0; i < loans.length; i++) {
    if(loans[i].total_paid > loans[i].total_paid_due) {
      numAdvanced++;
    } else if(loans[i].principal_balance > 0) {
      numPastDue++;
    }
  }

  return (
    <div>
      <div className="row">
        <div className="col-md-6">
          <h5>
            Repayment Rates
          </h5>
        </div>
        <div className="col-md-6">
          <div className="text-end">
            <label style={{marginRight: "12px"}}>
              Total Records: 
              <span className="badge bg-secondary">
                {numRecords}
              </span>
            </label>
            <label style={{marginRight: "12px"}}>
              Number of Past Due:
              <span className="badge bg-danger">
                {numPastDue}
              </span>
            </label>
            <label>
              Number of Advanced:
              <span className="badge bg-info">
                {numAdvanced}
              </span>
            </label>
          </div>
        </div>
      </div>

      <table className="table table-bordered table-hover table-sm" style={{fontSize: "0.75em"}}>
        <thead>
          <tr>
            <th>
            </th>
            <th style={{width: "20%"}}>
              Name
            </th>
            <th>
              Product
            </th>
            <th className="text-end">
              Principal
            </th>
            <th className="text-end">
              P. Paid
            </th>
            <th className="text-end">
              P. Bal
            </th>
            <th className="text-end">
              Interest
            </th>
            <th className="text-end">
              I. Paid
            </th>
            <th className="text-end">
              I. Bal.
            </th>
            <th className="text-end">
              Total Paid
            </th>
            <th className="text-end">
              Total Bal.
            </th>
            <th className="text-end">
              Paid Due
            </th>
            <th className="text-end">
              Past Due
            </th>
            <th className="text-end">
              Cum. Due
            </th>
            <th className="text-center">
              RR
            </th>
          </tr>
        </thead>
        <tbody>
          {renderDataRows()}
        </tbody>
      </table>
    </div>
  )
}

document.addEventListener('DOMContentLoaded', function() {
  var printButton = document.getElementById('btn-print-rp');
  var downloadButton = document.getElementById('btn-print-excel');

  if (printButton) {
    printButton.addEventListener('click', function() {
      var printWindow = window.open('', '', 'height=600,width=800');
      var tableHtml = document.querySelector('table').outerHTML; 
      tableHtml = tableHtml.replace(/<a[^>]*>(.*?)<\/a>/g, '$1');
      var repaymentTitle = document.getElementById('hidden-title').innerHTML;

      var headerHtml = `
        <style>
          .arial-font {
            font-family: Arial, sans-serif;
            color: black; 
            margin: 10px 5px;
          }
          h3 {
            font-size: 25px; 
            font-weight: bold; 
          }
          h4 {
            font-size: 15px; 
            font-weight: normal;
            font-weight: bold;
          }
        </style>
        <h3 class="arial-font">KASAGANA-KA CREDIT AND SAVINGS COOPERATIVE</h3>
        <h4 class="arial-font">4th Floor KMBA Members' Center Building #5 Matimpiin St. Brgy. Pinyahan Quezon City 1100</h4>
        <h4 class="arial-font">${repaymentTitle}</h4>
      `;

      printWindow.document.write('<style>body{font-family: Arial, sans-serif;} table{width: 100%; border-collapse: collapse;} th, td{border: 1px solid #000; padding: 5px; text-align: left;} th{background-color: #f2f2f2;} </style>'); 
      printWindow.document.write('</head><body>');
      printWindow.document.write(headerHtml);
      printWindow.document.write(tableHtml);
      printWindow.document.write('</body></html>');

      printWindow.document.close();
      printWindow.print();
    });
  }

  if (downloadButton) {
    downloadButton.addEventListener('click', function() {
      const table = document.querySelector('table');
      const rows = Array.from(table.querySelectorAll('tr'));
      
      const data = rows.map(row => 
        Array.from(row.querySelectorAll('td, th'))
          .map(cell => `"${cell.innerText.trim().replace(/"/g, '""')}"`)
          .join(",")
      ).join("\n");
    
      const blob = new Blob([data], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
      const url = URL.createObjectURL(blob);
    
      const link = document.createElement("a");
      link.setAttribute("href", url);
      link.setAttribute("download", "Repayment_Rate_Report.xlsx");
      document.body.appendChild(link);    
      link.click();
      document.body.removeChild(link);
    });
  }
});
