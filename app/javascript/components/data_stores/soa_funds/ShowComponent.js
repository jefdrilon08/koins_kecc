import React from 'react';
import $ from 'jquery';
import moment from 'moment';
import Select from 'react-select';
import Toggle from 'react-toggle';
import "react-toggle/style.css";

import SkCubeLoading from '../../SkCubeLoading';
import ErrorDisplay from '../../ErrorDisplay';
import {numberWithCommas} from '../../utils/helpers';

export default class ShowComponent extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false,
      errors: false,
      centers: [],
      officers: [],
      currentCenterId: "",
      currentLoanProductId: "",
      currentOfficerId: ""
    };
  }

  fetch(options) {
    var context   = this;
    var centerId  = options.centerId;
    var officerId = options.officerId;

    var data  = {
      id: this.props.id,
      center_id: centerId,
      officer_id: officerId
    }

    this.setState({
      currentCenterId: centerId,
      currentOfficerId: officerId
    });

    $.ajax({
      url: "/api/v1/data_stores/soa_funds/fetch",
      data: data,
      method: 'GET',
      success: function(response) {
        console.log(response);

        context.setState({
          isLoading: false,
          data: response
        });
      },
      error: function(response) {
        console.log(response);
        alert("Something went wrong when fetching data store");
      }
    });
  }

  componentDidMount() {
    var context = this;

    $.ajax({
      url: "/api/v1/data_stores/soa_funds/fetch",
      data: {
        id: context.props.id
      },
      method: 'GET',
      success: function(response) {
        console.log(response);

        var centers   = response.data.centers;
        var officers  = response.data.officers;

        context.setState({
          isLoading: false,
          data: response,
          centers: centers,
          officers: officers
        });
      },
      error: function(response) {
        console.log(response);
        alert("Something went wrong when fetching data store");
      }
    });
  }

  renderErrorDisplay() {
    if(this.state.errors) {
      return  (
        <ErrorDisplay
          errors={this.state.errors}
        />
      );
    }
  }

  renderPaymentRecords(paymentRecords, id) {
    var rows  = [];

    for(var j = 0; j < paymentRecords.length; j++) {
      rows.push(
        <td className="text-end" key={"payment-" + id + "-" + j + "debit"}>
          {paymentRecords[j].debit > 0 ? numberWithCommas(paymentRecords[j].debit) : ''}
        </td>
      );
      rows.push(
        <td className="text-end" key={"payment-" + id + "-" + j + "-credit"}>
          {paymentRecords[j].credit > 0 ? numberWithCommas(paymentRecords[j].credit) : ''}
        </td>
      );
    }

    return rows;
  }

  renderPayments(record) {
    var rows  = [];

    for(var i = 0; i < record.records.length; i++) {
      var payment         = record.records[i];
      var paymentRecords  = payment.records;

      rows.push(
        <tr key={"payment-record-" + record.member.id + "-" + i}>
          <td>
            {payment.date}
          </td>
          {this.renderPaymentRecords(paymentRecords, payment.id)}
        </tr>
      );
    }

    return rows;
  }

  renderSubtableHeaders(id) {
    var cols      = [];
    var settings  = this.state.data.data.settings;

    for(var i = 0; i < settings.length; i++) {
      cols.push(
        <td className="text-center" key={"header-" + id + "-" + settings[i].account_subtype} colSpan="2">
          <strong>
            {settings[i].account_subtype}
          </strong>
        </td>
      );
    }

    return cols;
  }
  renderDebitCreditHeaders(id) {
    var cols      = [];
    var settings  = this.state.data.data.settings;

    for(var i = 0; i < settings.length; i++) {
      cols.push(
        <td className="text-center">
          <strong>
            Debit
          </strong>
        </td>
      );
      cols.push(
        <td className="text-center">
          <strong>
            Credit
          </strong>
        </td>
      );
    }

    return cols;
  }

  renderSubtableTotals(totals, id) {
    var cols      = [];

    for(var i = 0; i < totals.length; i++) {
      cols.push(
        <td className="text-end" key={"total-" + id + "-" + i + "-debit"}>
          <strong>
            {totals[i].debit > 0 ? numberWithCommas(totals[i].debit) : ''}
          </strong>
        </td>
      );
      cols.push(
        <td className="text-end" key={"total-" + id + "-" + i + "-credit"}>
          <strong>
            {totals[i].credit > 0 ? numberWithCommas(totals[i].credit) : ''}
          </strong>
        </td>
      );
    }

    return cols;
  }

  renderDataRows() {
    var rows      = [];
    var records   = this.state.data.data.records;
    var settings  = this.state.data.data.settings;

    for(var i = 0; i < records.length; i++) {
      var r = records[i];

      rows.push(
        <tr key={"member-" + r.member.id} style={{backgroundColor: "#d0ccff"}}>
          <td colSpan={2 * (settings.length) + 1}>
            <strong>
              <a href={"/members/" + r.member.id + "/display"} target='_blank'>
                {r.member.last_name}, {r.member.first_name} &nbsp;
              </a>
            </strong>
            - &nbsp; 
            {r.center.name}
          </td>
        </tr>
      );

      rows.push(
        <tr key={"member-" + r.member.id + "-subtable-labels"}>
          <th key={"member-empty-date-" + r.member.id}>
            Date
          </th>
          {this.renderSubtableHeaders(r.member.id)}
        </tr>
      );

      rows.push(
        <tr key={"member-" + r.member.id + "-debit-credit-labels"}>
          <th key={"member-empty-dc-" + r.member.id}>
          </th>
          {this.renderDebitCreditHeaders(r.member.id)}
        </tr>
      );

      var memberDataRows  = this.renderPayments(r);

      for(var j = 0; j < memberDataRows.length; j++) {
        rows.push(memberDataRows[j]);
      }

      // TOTALS
      var totals  = records[i].totals;
      rows.push(
        <tr key={"member-" + r.member.id + "-totals"}>
          <td key={"totals-" + r.member.id}>
            <strong>
              Total
            </strong>
          </td>
          {this.renderSubtableTotals(totals, r.member.id)}
        </tr>
      );
    }

    return rows;
  }

  handleCenterChanged(event) {
    this.fetch({
      centerId: event.target.value,
      loanProductId: this.state.currentLoanProductId,
      officerId: this.state.currentOfficerId
    });
  }

  handleOfficerChanged(event) {
    this.fetch({
      centerId: this.state.currentCenterId,
      loanProductId: this.state.currentLoanProductId,
      officerId: event.target.value
    });
  }

  renderFilter() {
    var centerOptions   = [
      <option key={"center-select"} value="">
        -- SELECT --
      </option>
    ];

    for(var i = 0; i < this.state.centers.length; i++) {
      centerOptions.push(
        <option key={"center-" + i} value={this.state.centers[i].id}>
          {this.state.centers[i].name}
        </option>
      );
    }

    var officerOptions  = [
      <option key={"officer-select"} value="">
        -- SELECT --
      </option>
    ];

    for(var i = 0; i < this.state.officers.length; i++) {
      officerOptions.push(
        <option key={"officer-" + i} value={this.state.officers[i].id}>
          {this.state.officers[i].last_name}, {this.state.officers[i].first_name}
        </option>
      );
    }

    return  (
      <div className="row">
        <div className="col">
          <div className="form-group">
            <label>
              Center:
            </label>
            <select 
              value={this.state.currentCenterId} 
              onChange={this.handleCenterChanged.bind(this)} 
              className="form-control"
            >
              {centerOptions}
            </select>
          </div>
        </div>
        <div className="col">
          <div className="form-group">
            <label>
              Officer:
            </label>
            <select 
              value={this.state.currentOfficerId} 
              onChange={this.handleOfficerChanged.bind(this)} 
              className="form-control"
            >
              {officerOptions}
            </select>
          </div>
        </div>
      </div>
    );
  }

  renderTotalsRow() {
    var settings  = this.state.data.data.settings;
    var totals    = [];
    var totalVals = [];
    var records   = this.state.data.data.records;

    console.log(records);
    for(var i = 0; i < settings.length; i++) {
      totalVals.push({
        debit: 0.00,
        credit: 0.00
      });
    }

    for(var i = 0; i < records.length; i++) {
      for(var j = 0; j < records[i].records.length; j++) {
        for(var k = 0; k < records[i].records[j].records.length; k++) {

          // Increment credit
          totalVals[k].credit += parseFloat(records[i].records[j].records[k].credit);
          // Increment debit
          totalVals[k].debit += parseFloat(records[i].records[j].records[k].debit);
        }
      }
    }

    for(var i = 0; i < settings.length; i++) {

      totals.push(
        <td key={"grand-total-" + i + "-debit"} className="text-end">
          {numberWithCommas(totalVals[i].debit)}
        </td>
      );
      totals.push(
        <td key={"grand-total-" + i + "-credit"} className="text-end">
          {numberWithCommas(totalVals[i].credit)}
        </td>
      );
    }

    return  (
      <tr style={{backgroundColor: "yellow"}}>
        <td>
          <strong>
            Grand Total
          </strong>
        </td>
        {totals}
      </tr>
    );
  }

  render() {
    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else {
      return  (
        <div>
          {this.renderFilter()}
          <hr/>
          <table className="table table-sm table-bordered table-hover">
            <thead>
            </thead>
            <tbody>
              {this.renderDataRows()}
              {this.renderTotalsRow()}
            </tbody>
          </table>
        </div>
      );
    }
  }
}

document.addEventListener('DOMContentLoaded', function() {
  var printButton = document.getElementById('print_soaf');
  var downloadButton = document.getElementById('excel_soaf');

  if (printButton) {
    printButton.addEventListener('click', function() {
      var printWindow = window.open('', '', 'height=600,width=800');
      var tableHtml = document.querySelector('table').outerHTML; 
      tableHtml = tableHtml.replace(/<a[^>]*>(.*?)<\/a>/g, '$1');
      var Title = document.getElementById('hidden-title').innerHTML;

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
        <h4 class="arial-font">${Title}</h4>
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
    

      const blob = new Blob([data], { type: 'text/csv;charset=utf-8;' });

      const url = URL.createObjectURL(blob);

      const link = document.createElement("a");
      link.setAttribute("href", url);
      link.setAttribute("download", "SOA_Funds"); 
      document.body.appendChild(link);    
      link.click();
      document.body.removeChild(link);
    });
}
});
