import React from 'react';
import $ from 'jquery';
import moment from 'moment';
import Select from 'react-select';
import Toggle from 'react-toggle';
import "react-toggle/style.css";

import SkCubeLoading from '../../SkCubeLoading';
import ErrorDisplay from '../../ErrorDisplay';
import {numberWithCommas} from '../../utils/helpers';

export default class ShowDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false,
      errors: false,
      accountHeaders: []
    };
  }

  componentDidMount() {
    var context = this;

    var data  = {
      id: this.props.id
    }

    $.ajax({
      url: "/api/v1/data_stores/personal_funds/fetch",
      data: data,
      method: 'GET',
      success: function(response) {
        console.log(response);

        // Setup account headers
        var accountHeaders  = [];
        if(response.data.records.length > 0) {
          for(var i = 0; i < response.data.records[0].accounts.length; i++) {
            accountHeaders.push(
              response.data.records[0].accounts[i].account_subtype
            );
          }
        }

        context.setState({
          isLoading: false,
          accountHeaders: accountHeaders,
          data: response
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

  renderAccountHeaders() {
    var headers = [];

    // Member name
    headers.push(
      <th key="member-header">
        Member
      </th>
    );

    // Officer
    headers.push(
      <th key="officer-header">
        Officer
      </th>
    );

    // Center
    headers.push(
      <th key="center-header">
        Center
      </th>
    );

    console.log(this.state.accountHeaders);
    for(var i = 0; i < this.state.accountHeaders.length; i++) {
      headers.push(
        <th className="text-right" key={"account-header-" + i}>
          {this.state.accountHeaders[i]}
        </th>
      );
    }

    return headers;
  }

  renderAccountValues(index, accounts) {
    var columns = [];

    for(var i = 0; i < accounts.length; i++) {
      columns.push(
        <td className="text-right">
          {numberWithCommas(accounts[i].balance)}
        </td>
      );
    }

    return columns;
  }

  renderDataRows() {
    var rows  = [];
    var records = this.state.data.data.records;

    for(var i = 0; i < records.length; i++) {
      rows.push(
        <tr key={"record-item-" + i}>
          <td>
            {records[i].member.last_name + ", " + records[i].member.first_name + " " + records[i].member.middle_name}
          </td>
          <td>
            {records[i].officer.last_name + ", " + records[i].officer.first_name}
          </td>
          <td className="text-muted">
            {records[i].center.name}
          </td>
          {this.renderAccountValues(i, records[i].accounts)}
        </tr>
      );
    }

    return rows;
  }

  renderDataTotals() {
    var columns = [];
    var records = this.state.data.data.records;

    columns.push(
      <th colSpan="3">
        TOTAL: ({records.length})
      </th>
    );

    var totals  = [];

    for(var i = 0; i < this.state.accountHeaders.length; i++) {
      totals.push(0.00);
    }

    for(var i = 0; i < records.length; i++) {
      for(var j = 0; j < records[i].accounts.length; j++) {
        totals[j] += records[i].accounts[j].balance;
      }
    }

    for(var i = 0; i < totals.length; i++) {
      columns.push(
        <th className="text-right">
          {numberWithCommas(totals[i])}
        </th>
      );
    }

    return columns;
  }

  renderDisplay() {
    return  (
      <div>
        <table className="table table-sm table-bordered table-hover" style={{fontSize: "0.9em"}}>
          <thead>
            <tr>
              {this.renderAccountHeaders()}
            </tr>
          </thead>
          <tbody>
            {this.renderDataRows()}
          </tbody>
          <tfoot>
            <tr>
              {this.renderDataTotals()}
            </tr>
          </tfoot>
        </table>
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
          {this.renderDisplay()}
        </div>
      );
    }
  }
}
