import React from 'react';
import $ from 'jquery';
import moment from 'moment';

import SkCubeLoading from '../SkCubeLoading';
import BillingUITable from './BillingUITable';
import AccountingEntryPreview from '../accounting/AccountingEntryPreview';
import {numberWithCommas} from '../utils/helpers';

export default class BillingUIDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false
    };
  }

  componentDidMount() {
    this.fetchBillingData();
  }

  fetchBillingData() {
    var context = this;

    $.ajax({
      url: "/api/v1/billings/fetch",
      method: 'GET',
      data: {
        id: this.props.id
      },
      success: function(response) {
        context.setState({
          isLoading: false,
          data: response
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching billing");
      }
    });
  }

  updateData(data) {
    this.setState({
      data: data
    });
  }

  handleRemoveClicked(index) {
    alert("Not implemented for this module");
  }

  modifyOrNumber(event) {
    var context     = this;
    var newOrNumber = event.target.value;
    var data        = context.state.data;

    $.ajax({
      url: "/api/v1/billings/update_or_number",
      method: 'POST',
      data: {
        id: context.state.data.id,
        authenticity_token: context.props.authenticityToken,
        or_number: newOrNumber
      },
      success: function(response) {
        data.data.or_number                       = newOrNumber;
        data.data.accounting_entry.data.or_number = newOrNumber;

        context.setState({
          data: data
        });
      },
      error: function(response) {
        alert("Error in updating or number");
      }
    });
  }

  modifyArNumber(event) {
    var context     = this;
    var newArNumber = event.target.value;
    var data        = context.state.data;

    $.ajax({
      url: "/api/v1/billings/update_ar_number",
      method: 'POST',
      data: {
        id: context.state.data.id,
        authenticity_token: context.props.authenticityToken,
        ar_number: newArNumber
      },
      success: function(response) {
        data.data.ar_number                       = newArNumber;
        data.data.accounting_entry.data.ar_number = newArNumber;

        context.setState({
          data: data
        });
      },
      error: function(response) {
        alert("Error in updating ar number");
      }
    });
  }

  renderOrNumber() {
    var orNumber  = this.state.data.data.or_number;
    if(this.state.data.status == "pending") {
      return  (
        <input 
          value={orNumber} 
          onChange={this.modifyOrNumber.bind(this)} 
          className="form-control"
        />
      );
    } else {
      return this.state.data.data.or_number;
    }
  }

  renderArNumber() {
    var arNumber  = this.state.data.data.ar_number;
    if(this.state.data.status == "pending") {
      return  (
        <input 
          value={arNumber} 
          onChange={this.modifyArNumber.bind(this)} 
          className="form-control"
        />
      );
    } else {
      return this.state.data.data.ar_number;
    }
  }

  render() {
    if(this.state.isLoading) {
      return (
        <div>
          <SkCubeLoading/>
        </div>
      );
    } else {
      var accounting_entry_data = this.state.data.data.accounting_entry;

      return (
        <div>
          <table className="table table-sm table-bordered">
            <tbody>
              <tr>
                <th>
                  Expected Collections:
                </th>
                <td className="text-right">
                  <div className="text-muted">
                    {numberWithCommas(this.state.data.data.total_expected_collections)}
                  </div>
                </td>
              </tr>
              <tr>
                <th>
                  Total Collected:
                </th>
                <td className="text-right">
                  <strong>
                    {numberWithCommas(this.state.data.data.total_collected)}
                  </strong>
                </td>
              </tr>
              <tr>
                <th>
                  OR Number:
                </th>
                <td className="text-right">
                  {this.renderOrNumber()}
                </td>
              </tr>
              <tr>
                <th>
                  AR Number:
                </th>
                <td className="text-right">
                  {this.renderArNumber()}
                </td>
              </tr>
            </tbody>
          </table>
          <hr/>
          <BillingUITable
            id={this.props.id}
            data={this.state.data}
            updateData={this.updateData.bind(this)}
            authenticityToken={this.props.authenticityToken}
          />
          <hr/>
          <h6>
            Accounting Entry
          </h6>
          <AccountingEntryPreview
            book={accounting_entry_data.book}
            particular={accounting_entry_data.particular}
            datePrepared={moment(accounting_entry_data.date_prepared).format("YYYY-MM-DD")}
            branch={accounting_entry_data.branch_name}
            balanced={true}
            status={accounting_entry_data.status}
            journalEntries={accounting_entry_data.journal_entries}
            isLoading={this.state.isLoading}
            handleRemoveClicked={this.handleRemoveClicked.bind(this)}
            data={accounting_entry_data.data}
          />
        </div>
      );
    }
  }
}
