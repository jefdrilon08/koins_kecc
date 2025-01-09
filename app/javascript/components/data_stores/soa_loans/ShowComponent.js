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
      loanProducts: [],
      currentLoanProductId: "",
      currentOfficerId: ""
    };
  }

  fetch(options) {
    var context       = this;
    var loanProductId = options.loanProductId;
    var centerId      = options.centerId;
    var officerId     = options.officerId;

    var data  = {
      id: this.props.id,
      loan_product_id: loanProductId,
      center_id: centerId,
      officer_id: officerId
    }

    this.setState({
      currentLoanProductId: loanProductId,
      currentCenterId: centerId,
      currentOfficerId: officerId
    });

    $.ajax({
      url: "/api/v1/data_stores/soa_loans/fetch",
      data: data,
      method: 'GET',
      success: function(response) {
        context.setState({
          isLoading: false,
          data: response
        });
      },
      error: function(response) {
        alert("Something went wrong when fetching data store");
      }
    });
  }

  componentDidMount() {
    var context = this;

    $.ajax({
      url: "/api/v1/data_stores/soa_loans/fetch",
      data: {
        id: context.props.id
      },
      method: 'GET',
      success: function(response) {
        console.log(response);

        var loanProducts  = response.data.loan_products;
        var centers       = response.data.centers;
        var officers      = response.data.officers;

        context.setState({
          isLoading: false,
          data: response,
          loanProducts: loanProducts,
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

  renderPayments(record) {
    var rows  = [];

    for(var i = 0; i < record.records.length; i++) {
      var payment = record.records[i];

      rows.push(
        <tr key={"payment-" + payment.id}>
          <td>
            {payment.date}
          </td>
          <td className="text-end">
            {numberWithCommas(payment.principal_paid)}
          </td>
          <td className="text-end">
            {numberWithCommas(payment.interest_paid)}
          </td>
          <td className="text-end">
            {numberWithCommas(parseFloat(payment.principal_paid) + parseFloat(payment.interest_paid))}
          </td>
        </tr>
      );
    }

    return rows;
  }

  renderTotals() {
    var total_principal_paid  = 0.00;
    var total_interest_paid   = 0.00;

    var records = this.state.data.data.records;

    for(var i = 0; i < records.length; i++) {
      total_principal_paid += parseFloat(records[i].total_principal_paid);
      total_interest_paid += parseFloat(records[i].total_interest_paid);
    }

    var total_paid  = total_principal_paid + total_interest_paid;

    return  (
      <tr key="grand-total" style={{backgroundColor: "yellow"}}>
        <th className="">
          GRAND TOTAL
        </th>
        <th className="text-end">
          {numberWithCommas(total_principal_paid)}
        </th>
        <th className="text-end">
          {numberWithCommas(total_interest_paid)}
        </th>
        <th className="text-end">
          {numberWithCommas(total_paid)}
        </th>
      </tr>
    );

  }

  renderDataRows() {
    var rows  = [];
    var records = this.state.data.data.records;

    for(var i = 0; i < records.length; i++) {
      var r = records[i];

      rows.push(
        <tr key={"member-" + i} style={{backgroundColor: "#d0ccff"}}>
          <td colSpan="4">
            <strong>
              {r.member.last_name}, {r.member.first_name} &nbsp;
            </strong>
            <small className="text-muted">
              {r.loan_product.name}
            </small>
          </td>
        </tr>
      );

      rows.push(
        <tr key={"member-" + i + "-labels"}>
          <th>
            Date
          </th>
          <th className="text-end">
            Principal
          </th>
          <th className="text-end">
            Interest
          </th>
          <th className="text-end">
            Total
          </th>
        </tr>
      );

      var memberDataRows  = this.renderPayments(r);

      for(var j = 0; j < memberDataRows.length; j++) {
        rows.push(memberDataRows[j]);
      }

      rows.push(
        <tr key={"member-" + i + "-grand-total"}>
          <th>
            <strong>
              Total for {r.member.last_name}, {r.member.first_name} &nbsp;
            </strong>
            <small className="text-muted">
              {r.loan_product.name}
            </small>
          </th>
          <th className="text-end">
            {numberWithCommas(r.total_principal_paid)}
          </th>
          <th className="text-end">
            {numberWithCommas(r.total_interest_paid)}
          </th>
          <th className="text-end">
            {numberWithCommas(parseFloat(r.total_principal_paid) + parseFloat(r.total_interest_paid))}
          </th>
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

  handleLoanProductChanged(event) {
    this.fetch({
      loanProductId: event.target.value,
      centerId: this.state.currentCenterId,
      officerId: this.state.currentOfficerId
    });
  }

  handleOfficerChanged(event) {
    this.fetch({
      loanProductId: this.state.currentLoanProductId,
      centerId: this.state.currentCenterId,
      officerId: event.target.value
    });
  }

  renderFilter() {
    var loanProductOptions  = [
      <option key={"select-loan-product"} value="">
        -- SELECT --
      </option>
    ];

    var centerOptions   = [
      <option key={"center-select"} value="">
        -- SELECT --
      </option>
    ];

    var officerOptions  = [
      <option key={"officer-select"} value="">
        -- SELECT --
      </option>
    ];

    for(var i = 0; i < this.state.loanProducts.length; i++) {
      loanProductOptions.push(
        <option key={"loanProduct-" + i} value={this.state.loanProducts[i].id}>
          {this.state.loanProducts[i].name}
        </option>
      );
    }

    for(var i = 0; i < this.state.centers.length; i++) {
      centerOptions.push(
        <option key={"center-" + i} value={this.state.centers[i].id}>
          {this.state.centers[i].name}
        </option>
      );
    }

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
              Loan Product:
            </label>
            <select value={this.state.currentLoanProductId} onChange={this.handleLoanProductChanged.bind(this)} className="form-control">
              {loanProductOptions}
            </select>
          </div>
        </div>
        <div className="col">
          <div className="form-group">
            <label>
              Center:
            </label>
            <select value={this.state.currentCenterId} onChange={this.handleCenterChanged.bind(this)} className="form-control">
              {centerOptions}
            </select>
          </div>
        </div>
        <div className="col">
          <div className="form-group">
            <label>
              Officer:
            </label>
            <select value={this.state.currentOfficerId} onChange={this.handleOfficerChanged.bind(this)} className="form-control">
              {officerOptions}
            </select>
          </div>
        </div>
      </div>
    );
  }

  renderTotal() {
    var total = 0.00;

    for(var i = 0; i < this.state.data.data.records.length; i++) {
      total += parseFloat(this.state.data.data.records[i].principal);
    }

    return  (
      <tr>
        <th colSpan="3">
          TOTAL
        </th>
        <td className="text-end">
          <strong>
            {numberWithCommas(total)}
          </strong>
        </td>
        <td>
        </td>
        <td>
        </td>
      </tr>
    );
  }

  renderDisplay() {
    return  (
      <div>
        <hr/>
        {this.renderTotals()}
        <hr/>
        {this.renderDataRows()}
      </div>
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
          <table className="table table-sm table-bordered table-hover">
            <thead>
            </thead>
            <tbody>
              {this.renderDataRows()}
            </tbody>
            <tfoot>
              {this.renderTotals()}
            </tfoot>
          </table>
        </div>
      );
    }
  }
}

document.addEventListener('DOMContentLoaded', function() {
  var printButton = document.getElementById('print_soal');
  var downloadButton = document.getElementById('excel_soal');

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
      link.setAttribute("download", "SOA_Loans"); 
      document.body.appendChild(link);    
      link.click();
      document.body.removeChild(link);
    });
}
});

