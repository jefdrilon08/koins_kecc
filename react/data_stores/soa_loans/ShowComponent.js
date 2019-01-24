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
      loanProducts: [],
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
      url: "/api/v1/data_stores/soa_loans/fetch",
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
      url: "/api/v1/data_stores/soa_loans/fetch",
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

  renderPayments(record) {
    var rows  = [];

    for(var i = 0; i < record.records.length; i++) {
      var payment = record.records[i];

      rows.push(
        <tr key={"payment-" + i}>
          <td>
            {payment.date}
          </td>
          <td className="text-right">
            {numberWithCommas(payment.principal_paid)}
          </td>
          <td className="text-right">
            {numberWithCommas(payment.interest_paid)}
          </td>
        </tr>
      );
    }

    return rows;
  }

  renderDataRows() {
    var rows  = [];
    var records = this.state.data.data.records;

    for(var i = 0; i < records.length; i++) {
      var r = records[i];
      rows.push(
        <div>
          <h5>
            {r.member.last_name}, {r.member.first_name} &nbsp;
            <small className="text-muted">
              {r.loan_product.name}
            </small>
          </h5>
          <table className="table table-bordered table-sm table-xs table-hover">
            <thead>
              <tr>
                <th>
                  Date
                </th>
                <th className="text-right">
                  Principal
                </th>
                <th className="text-right">
                  Interest
                </th>
              </tr>
            </thead>
            <tbody>
              {this.renderPayments(r)}
            </tbody>
            <tfoot>
              <tr>
                <th>
                  TOTAL
                </th>
                <th className="text-right">
                  {numberWithCommas(r.total_principal_paid)}
                </th>
                <th className="text-right">
                  {numberWithCommas(r.total_interest_paid)}
                </th>
              </tr>
            </tfoot>
          </table>
        </div>
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

    console.log(this.state.loanProducts);

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
          {this.renderDisplay()}
        </div>
      );
    }
  }
}
