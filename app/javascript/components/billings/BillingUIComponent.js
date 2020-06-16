import React from 'react';
import $ from 'jquery';
import moment from 'moment';

import SkCubeLoading from '../SkCubeLoading';
import BillingUITable from './BillingUITable';
import AccountingEntryPreview from '../accounting/AccountingEntryPreview';
import {numberWithCommas} from '../utils/helpers';

export default class BillingUIComponent extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      isSaving: false,
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

  saveParticular() {
    var context       = this;
    var data          = context.state.data;
    var newParticular = data.data.accounting_entry.particular;

    context.setState({
      isSaving: true
    });

    $.ajax({
      url: "/api/v1/billings/update_particular",
      method: 'POST',
      data: {
        id: context.state.data.id,
        authenticity_token: context.props.authenticityToken,
        particular: newParticular
      },
      success: function(response) {
        context.setState({
          isSaving: false
        });
      },
      error: function(response) {
        alert("Error in updating particular");
      }
    });
  }

  handleBookChanged(event) {
    var context = this;
    var data    = context.state.data;
    var book    = event.target.value;

    context.setState({
      isSaving: true
    });

    $.ajax({
      url: "/api/v1/billings/update_book",
      method: 'POST',
      data: {
        id: context.state.data.id,
        authenticity_token: context.props.authenticityToken,
        book: book
      },
      success: function(response) {
        data.data.accounting_entry.book = book;

        context.setState({
          isSaving: false
        });

        context.updateData(data);
      },
      error: function(response) {
        alert("Error in updating particular");
      }
    });
  }

  saveOrNumber() {
    var context     = this;
    var data        = context.state.data;
    var newOrNumber = data.data.accounting_entry.data.or_number;

    context.setState({
      isSaving: true
    });

    $.ajax({
      url: "/api/v1/billings/update_or_number",
      method: 'POST',
      data: {
        id: context.state.data.id,
        authenticity_token: context.props.authenticityToken,
        or_number: newOrNumber
      },
      success: function(response) {
        context.setState({
          isSaving: false
        });
      },
      error: function(response) {
        alert("Error in updating or number");
      }
    });
  }

  modifyOrNumber(event) {
    var context     = this;
    var newOrNumber = event.target.value;
    var data        = context.state.data;

    data.data.or_number                       = newOrNumber;
    data.data.accounting_entry.data.or_number = newOrNumber;

    context.setState({
      data: data
    });
  }

  modifyParticular(event) {
    var context       = this;
    var newParticular = event.target.value;
    var data          = context.state.data;

    data.data.accounting_entry.particular = newParticular;

    context.setState({
      data: data
    });
  }

  saveArNumber() {
    var context     = this;
    var data        = context.state.data;
    var newArNumber = data.data.accounting_entry.data.ar_number;

    context.setState({
      isSaving: true
    });

    $.ajax({
      url: "/api/v1/billings/update_ar_number",
      method: 'POST',
      data: {
        id: context.state.data.id,
        authenticity_token: context.props.authenticityToken,
        ar_number: newArNumber
      },
      success: function(response) {
        context.setState({
          isSaving: false
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

    data.data.ar_number                       = newArNumber;
    data.data.accounting_entry.data.ar_number = newArNumber;

    context.setState({
      data: data
    });
  }

  renderParticular() {
    var particular  = this.state.data.data.accounting_entry.particular;

    if(this.state.data.status == "pending") {
      return  (
        <div className="row">
          <div className="col-md-10">
            <input 
              value={particular} 
              onChange={this.modifyParticular.bind(this)} 
              disabled={this.state.isSaving}
              className="form-control"
            />
          </div>
          <div className="col-md-2">
            <button
              className="btn btn-info btn-block"
              disabled={this.state.isSaving}
              onClick={this.saveParticular.bind(this)}
            >
              <span className="fa fa-check"/>
              Save
            </button>
          </div>
        </div>
      );
    } else {
      return particular;
    }
  }

  renderOrNumber() {
    var orNumber  = this.state.data.data.or_number;

    if(this.state.data.status == "pending") {
      return  (
        <div className="row">
          <div className="col-md-10">
            <input 
              value={orNumber} 
              onChange={this.modifyOrNumber.bind(this)} 
              disabled={this.state.isSaving}
              className="form-control"
            />
          </div>
          <div className="col-md-2">
            <button
              className="btn btn-info btn-block"
              disabled={this.state.isSaving}
              onClick={this.saveOrNumber.bind(this)}
            >
              <span className="fa fa-check"/>
              Save
            </button>
          </div>
        </div>
      );
    } else {
      return this.state.data.data.or_number;
    }
  }

  renderBook() {
    var book  = this.state.data.data.accounting_entry.book;

    if(this.state.data.status == "pending") {
      return (
        <div className="row">
          <div className="col">
            <select
              value={book}
              disabled={this.state.isLoading}
              onChange={this.handleBookChanged.bind(this)}
              className="form-control"
            >
              <option value="CRB">CRB</option>
              <option value="JVB">JVB</option>
            </select>
          </div>
        </div>
      );
    } else {
      return book;
    }
  }

  renderArNumber() {
    var arNumber  = this.state.data.data.ar_number;
    if(this.state.data.status == "pending") {
      return  (
        <div className="row">
          <div className="col-md-10">
            <input 
              value={arNumber} 
              onChange={this.modifyArNumber.bind(this)} 
              disabled={this.state.isSaving}
              className="form-control"
            />
          </div>
          <div className="col-md-2">
            <button
              className="btn btn-info btn-block"
              disabled={this.state.isSaving}
              onClick={this.saveArNumber.bind(this)}
            >
              <span className="fa fa-check"/>
              Save
            </button>
          </div>
        </div>
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
      console.log(accounting_entry_data);

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
                  Book:
                </th>
                <td className="text-right">
                  {this.renderBook()}
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
              <tr>
                <th>
                  Particular:
                </th>
                <td className="text-right">
                  {this.renderParticular()}
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
            datePrepared={accounting_entry_data.date_prepared}
            referenceNumber={accounting_entry_data.reference_number}
            approved_by={accounting_entry_data.approved_by}
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
