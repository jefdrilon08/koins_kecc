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
      currentCenterId: "",
      currentLoanProductId: ""
    };
  }

  fetch(options) {
    var context       = this;
    var loanProductId = options.loanProductId;
    var centerId      = options.centerId;

    var data  = {
      id: this.props.id,
      loan_product_id: loanProductId,
      center_id: centerId
    }

    console.log("fetch (data):");
    console.log(data);

    this.setState({
      currentLoanProductId: loanProductId,
      currentCenterId: centerId
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

        var loanProducts  = response.data.loan_products;
        var centers       = response.data.centers;

        context.setState({
          isLoading: false,
          data: response,
          loanProducts: loanProducts,
          centers: centers
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
        <td className="text-right" key={"payment-" + id + "-" + j + "debit"}>
          {paymentRecords[j].debit > 0 ? numberWithCommas(paymentRecords[j].debit) : ''}
        </td>
      );
      rows.push(
        <td className="text-right" key={"payment-" + id + "-" + j + "-credit"}>
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
        <tr key={"payment-" + payment.id}>
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

  renderSubtableTotals(totals, id) {
    var cols      = [];

    for(var i = 0; i < totals.length; i++) {
      cols.push(
        <td className="text-right" key={"total-" + id + "-" + i + "-debit"}>
          <strong>
            {totals[i].debit > 0 ? numberWithCommas(totals[i].debit) : ''}
          </strong>
        </td>
      );
      cols.push(
        <td className="text-right" key={"total-" + id + "-" + i + "-debit"}>
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
        <tr key={"member-" + i} style={{backgroundColor: "#d0ccff"}}>
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
        <tr key={"member-" + i + "-labels"}>
          <th>
            Date
          </th>
          {this.renderSubtableHeaders(r.member.id)}
        </tr>
      );

      var memberDataRows  = this.renderPayments(r);

      for(var j = 0; j < memberDataRows.length; j++) {
        rows.push(memberDataRows[j]);
      }

      // TOTALS
      var totals  = records[i].totals;
      rows.push(
        <tr key={"member-" + i + "-totals"}>
          <td>
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
      loanProductId: this.state.currentLoanProductId
    });
  }

  handleLoanProductChanged(event) {
    this.fetch({
      loanProductId: event.target.value,
      centerId: this.state.currentCenterId
    });
  }

  renderFilter() {
    var centerOptions   = [
      <option key={"center-select"} value="">
        -- SELECT --
      </option>
    ];

    console.log(this.state.loanProducts);

    for(var i = 0; i < this.state.centers.length; i++) {
      centerOptions.push(
        <option key={"center-" + i} value={this.state.centers[i].id}>
          {this.state.centers[i].name}
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
        <td className="text-right">
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
          <table className="table table-sm table-bordered table-hover">
            <thead>
            </thead>
            <tbody>
              {this.renderDataRows()}
            </tbody>
          </table>
        </div>
      );
    }
  }
}
