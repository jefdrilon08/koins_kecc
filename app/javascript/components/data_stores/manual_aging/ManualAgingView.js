import React from 'react';
import {numberWithCommas, numberAsPercent} from '../../utils/helpers';

export default class ManualAgingView extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
    }
  }

  renderDataRows() {
    var loans = this.props.data.data.records;
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
                  {center.name}
                </small>
              </strong>
            </a>
          </td>
          <td>
            {loanProduct.name}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].principal)}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].principal_paid)}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].overall_principal_balance)}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].interest)}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].interest_paid)}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].overall_interest_balance)}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].total_paid)}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].overall_balance)}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].principal_paid_due)}
          </td>
          <td className="text-right">
            {numberWithCommas(loans[i].principal_balance)}
          </td>
          <td className="text-right">
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
        <th className="text-right">
          {numberWithCommas(totalPrincipal)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalPrincipalPaid)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalOverallPrincipalBalance)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalInterest)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalInterestPaid)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalOverallInterestBalance)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalTotalPaid)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalOverallBalance)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalPrincipalPaidDue)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalPrincipalBalance)}
        </th>
        <th className="text-right">
          {numberWithCommas(totalPrincipalDue)}
        </th>
        <th className="text-center">
          {numberAsPercent(totalPrincipalRR)}
        </th>
        
      </tr>
    );

    return rows;
  }

  render() {
    var numRecords  = 0;
    var numPastDue  = 0;
    var numAdvanced = 0;

    var loans = this.props.data.data.records;

    numRecords  = loans.length;

    for(var i = 0; i < loans.length; i++) {
      if(loans[i].total_paid > loans[i].total_paid_due) {
        numAdvanced++;
      } else if(loans[i].principal_balance > 0) {
        numPastDue++;
      }
    }

    return  (
      <div>
        <div className="row">
          <div className="col-md-6">
            <h5>
              Repayment Rates
            </h5>
          </div>
          <div className="col-md-6">
            <div className="text-right">
              <label style={{marginRight: "12px"}}>
                Total Records: 
                <span className="badge badge-secondary">
                  {numRecords}
                </span>
              </label>
              <label style={{marginRight: "12px"}}>
                Number of Past Due:
                <span className="badge badge-danger">
                  {numPastDue}
                </span>
              </label>
              <label>
                Number of Advanced:
                <span className="badge badge-info">
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
              <th className="text-right">
                Principal
              </th>
              <th className="text-right">
                P. Paid
              </th>
              <th className="text-right">
                P. Bal
              </th>
              <th className="text-right">
                Interest
              </th>
              <th className="text-right">
                I. Paid
              </th>
              <th className="text-right">
                I. Bal.
              </th>
              <th className="text-right">
                Total Paid
              </th>
              <th className="text-right">
                Total Bal.
              </th>
              <th className="text-right">
                Paid Due
              </th>
              <th className="text-right">
                Past Due
              </th>
              <th className="text-right">
                Cum. Due
              </th>
              <th className="text-center">
                RR
              </th>
            </tr>
          </thead>
          <tbody>
            {this.renderDataRows()}
          </tbody>
        </table>
      </div>
    );
  }
}
