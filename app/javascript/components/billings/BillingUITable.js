import React from 'react';
import ReactTable from 'react-table';
import Modal from 'react-modal';
import Toggle from 'react-toggle';
import "react-toggle/style.css";

import {numberWithCommas} from '../utils/helpers';
import {customStyles} from '../utils/consts';

import ErrorDisplay from '../ErrorDisplay';

export default class BillingUITable extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      currentTransaction: false,
      currentAmountValue: false,
      currentMember: false,
      modalIsOpen: false,
      isLoading: false,
      errors: false,
      grandTotal: 0.00
    };
  }

  buildHeaders() {
    var headers = [];

    headers.push(
      <th key={"h-member-attendance"} style={{minWidth: "100px"}}>
        <center>
          <small>
            Attend.
          </small>
          <br/>
          <div className="btn-group">
            <div 
              className="btn btn-success btn-sm"
              onClick={this.handleToggleAllOn.bind(this)}
            >
              <span className="fa fa-check"/>
            </div>
            <div 
              className="btn btn-danger btn-sm"
              onClick={this.handleToggleAllOff.bind(this)}
            >
              <span className="fa fa-times"/>
            </div>
          </div>
        </center>
      </th>
    );

    headers.push(
      <th key={"h-member"} style={{minWidth: "300px"}}>
        Member
      </th>
    );

    for(var i = 0; i < this.props.data.data.headers.length; i++) {
      headers.push(
        <th key={"h-" + i} style={{minWidth: "100px"}}>
          <center>
            <small>
              {this.props.data.data.headers[i]}
            </small>
          </center>
        </th>
      );
    }

    headers.push(
      <th  key={"h-total"} style={{minWidth: "40px"}}>
        <center>
          CP
        </center>
      </th>
    );

    headers.push(
      <th  key={"h-grand-total"} style={{minWidth: "40px"}}>
        <center>
          TOTAL
        </center>
      </th>
    );

    return headers;
  }

  handleToggleAllOn() {
    var context = this;

    var data  = {
      id: this.props.id,
      authenticity_token: this.props.authenticityToken
    };

    $.ajax({
      url: "/api/v1/billings/toggle_attendance_on",
      method: 'POST',
      data: data,
      success: function(response) {
        context.props.updateData(response);
        window.location.reload();
      },
      error: function(response) {
        alert("Error in toggling attendance (all on)");
      }
    });
  }

  handleToggleAllOff() {
    var context = this;

    var data  = {
      id: this.props.id,
      authenticity_token: this.props.authenticityToken
    };

    $.ajax({
      url: "/api/v1/billings/toggle_attendance_off",
      method: 'POST',
      data: data,
      success: function(response) {
        context.props.updateData(response);
        window.location.reload();
      },
      error: function(response) {
        alert("Error in toggling attendance (all off)");
      }
    });
  }

  handleToggled(memberId) {
    var context = this;

    var data  = {
      member_id: memberId,
      id: this.props.id,
      authenticity_token: this.props.authenticityToken
    };

    $.ajax({
      url: "/api/v1/billings/toggle_attendance",
      method: 'POST',
      data: data,
      success: function(response) {
        context.props.updateData(response);
      },
      error: function(response) {
        alert("Error in toggling attendance");
      }
    });
  }

  fetchGrandTotal() {
    var t = 0.00
    for(var i = 0; i < this.props.data.data.records.length; i++) {
      for(var j = 0; j < this.props.data.data.records[i].records.length; j++) {
        var paymentRecord = this.props.data.data.records[i].records[j];
        t += parseFloat(paymentRecord.amount);
      }
    }

    return t;
  }


  buildRecords() {
    var records = [];

    for(var i = 0; i < this.props.data.data.records.length; i++) {
      var components  = [];
      var record      = this.props.data.data.records[i];
      var member      = record.member;
      var grandTotal  = 0.00;
      
      if(this.props.data.status == "pending") {
        components.push(
          <td key={"c-member-attnd-" + member.id}>
            <center>
              <Toggle
                defaultChecked={record.attendance}
                onChange={this.handleToggled.bind(this, member.id)}
                className="btn"
              />
            </center>
          </td>
        );
      } else if(record.attendance) {
        components.push(
          <td key={"c-member-attnd-" + member.id}>
            <center>
              <div className="badge badge-success">
                <span className="fa fa-check"/>
              </div>
            </center>
          </td>
        );
      } else {
        components.push(
          <td key={"c-member-attnd-" + member.id}>
            <center>
              <div className="badge badge-danger">
                <span className="fa fa-minus"/>
              </div>
            </center>
          </td>
        );
      }

      components.push(
        <td key={"c-member-" + member.id}>
          <strong>
            <a href={"/members/" + member.id + "/display"} target="_blank">
              {this.props.data.data.records[i].member.full_name} -

            </a>
          </strong>
            <small>
              {this.props.data.data.records[i].member.member_type}
            </small>
        </td>
      );

      for(var j = 0; j < this.props.data.data.records[i].records.length; j++) {

        var paymentRecord = this.props.data.data.records[i].records[j];

        if(paymentRecord.record_type == "LOAN_PAYMENT" && paymentRecord.enabled == true) {
          if(this.props.data.status == "pending"  && this.props.data.data.is_checked == null || this.props.data.data.is_checked == false) {
            components.push(
              <td key={"loan-payment-" + paymentRecord.loan_id} className="text-right">
                <strong>
                  <a 
                    href="#"
                    onClick={this.handleTransactionClicked.bind(this, paymentRecord, member)}
                  >
                    {numberWithCommas(paymentRecord.amount)}
                  </a>
                </strong>
              </td>
            );
          } else {
            components.push(
              <td key={"loan-payment-" + paymentRecord.loan_id} className="text-right">
                {numberWithCommas(paymentRecord.amount)}
              </td>
            );
          }

          // Add grand total
          grandTotal += parseFloat(paymentRecord.amount);
        } else if(paymentRecord.record_type == "SAVINGS" && paymentRecord.enabled == true) {
          if(this.props.data.status == "pending" && this.props.data.data.is_checked == null || this.props.data.data.is_checked == false )  {
            components.push(
              <td key={"savings-" + paymentRecord.member_account_id} className="text-right">
                <strong>
                  <a 
                    href="#"
                    onClick={this.handleTransactionClicked.bind(this, paymentRecord, member)}
                  >
                    {numberWithCommas(paymentRecord.amount)}
                  </a>
                </strong>
              </td>
            );
          } else {
            components.push(
              <td key={"savings-" + paymentRecord.member_account_id} className="text-right">
                {numberWithCommas(paymentRecord.amount)}
              </td>
            );
          }

          // Add grand total
          grandTotal += parseFloat(paymentRecord.amount);
        } else if(paymentRecord.record_type == "INSURANCE" && paymentRecord.enabled == true) {
          if(this.props.data.status == "pending" && this.props.data.data.is_checked == null || this.props.data.data.is_checked == false) {
            components.push(
              <td key={"insurance-" + paymentRecord.member_account_id} className="text-right">
                <strong>
                  <a 
                    href="#"
                    onClick={this.handleTransactionClicked.bind(this, paymentRecord, member)}
                  >
                    {numberWithCommas(paymentRecord.amount)}
                  </a>
                </strong>
              </td>
            );
          } else {
            components.push(
              <td key={"insurance-" + paymentRecord.member_account_id} className="text-right">
                {numberWithCommas(paymentRecord.amount)}
              </td>
            );
          }

          // Add grand total
          grandTotal += parseFloat(paymentRecord.amount);
        } else if(paymentRecord.record_type == "WP" && paymentRecord.enabled == true) {
          if(this.props.data.status == "pending"  && this.props.data.data.is_checked == null || this.props.data.data.is_checked == false) {
            components.push(
              <td key={"WP-" + paymentRecord.member_account_id} className="text-right">
                <strong>
                  <a 
                    href="#"
                    onClick={this.handleTransactionClicked.bind(this, paymentRecord, member)}
                  >
                    {numberWithCommas(paymentRecord.amount)}
                  </a>
                </strong>
              </td>
            );
          } else {
            components.push(
              <td key={"WP-" + paymentRecord.member_account_id} className="text-right">
                {numberWithCommas(paymentRecord.amount)}
              </td>
            );
          }
        } else {
          components.push(
            <td key={"na-" + member.id + "-" + j}>
            </td>
          )
        }
      }

      components.push(
        <td key={"c-member-total-" + member.id} className="text-right">
          <strong>
            {numberWithCommas(this.props.data.data.records[i].total_collected)}
          </strong>
        </td>
      );

      components.push(
        <td key={"c-member-grand-total-" + member.id} className="text-right">
          <strong>
            {numberWithCommas(grandTotal)}
          </strong>
        </td>
      );
      //alert(grandTotal);

      records.push(
        <tr key={"member-row-" + i} style={{ backgroundColor: (record.attendance ? '' : '') }}>
          {components}
        </tr>
      );
    }

    return records;
  }

  buildTotals() {
    var records     = [];
    var grandTotal  = 0.00;

    records.push(
      <td key="total-empty-td-0">
      </td>
    );

    records.push(
      <td key="total-label">
        <strong>
          TOTAL
        </strong>
      </td>
    );

    var totals  = this.props.data.data.totals;
    for(var i = 0; i < totals.length; i++) {
      if(totals[i].record_type == "LOAN_PAYMENT") {
        grandTotal += parseFloat(totals[i].amount);

        records.push(
          <td key={"total-loan-payment-" + totals[i].key} className="text-right">
            <strong>
              {numberWithCommas(totals[i].amount)}
            </strong>
          </td>
        );
      } else if(totals[i].record_type == "SAVINGS") {
        grandTotal += parseFloat(totals[i].amount);

        records.push(
          <td key={"total-savings-" + totals[i].key} className="text-right">
            <strong>
              {numberWithCommas(totals[i].amount)}
            </strong>
          </td>
        );
      } else if(totals[i].record_type == "INSURANCE") {
        grandTotal += parseFloat(totals[i].amount);

        records.push(
          <td key={"total-insurance-" + totals[i].key} className="text-right">
            <strong>
              {numberWithCommas(totals[i].amount)}
            </strong>
          </td>
        );
      } else if(totals[i].record_type == "WP") {
        records.push(
          <td key={"wp-" + totals[i].key} className="text-right">
            <strong>
              {numberWithCommas(totals[i].amount)}
            </strong>
          </td>
        );
      }
    }

    records.push(
      <td key="grand-total" className="text-right">
        <div className="badge badge-success">
          <strong>
            {numberWithCommas(this.props.data.data.total_collected)}
          </strong>
        </div>
      </td>
    )

    // Grand Total
    records.push(
      <td key="grand-total-final" className="text-right">
        <div className="badge badge-info">
          <strong>
            {numberWithCommas(grandTotal)}
          </strong>
        </div>
      </td>
    )

    return (
      <tr key={"totals-row"}>
        {records}
      </tr>
    );
  }

  handleTransactionClicked(paymentRecord, member) {
    this.setState({
      modalIsOpen: true,
      currentTransaction: paymentRecord,
      currentMember: member,
      currentAmountValue: paymentRecord.amount
    });
  }

  handleModalClose() {
    var currentTransaction    = this.state.currentTransaction;
    currentTransaction.amount = this.state.currentAmountValue;

    this.setState({
      modalIsOpen: false,
      currentTransaction: false,
      currentMember: false,
      currentAmountValue: false,
      errors: false
    });
  }

  handleInputAmountChanged(event) {
    var currentTransaction  = this.state.currentTransaction;

    if(currentTransaction) {
      currentTransaction.amount = event.target.value;

      this.setState({
        currentTransaction: currentTransaction
      });
    }
  }

  renderTransactionParticular() {
    var currentTransaction  = this.state.currentTransaction;
    var currentMember       = this.state.currentMember;

    if(currentTransaction.record_type == "LOAN_PAYMENT") {
      return (
        <h5>
          Loan Product: &nbsp;
          <span className="text-muted">
            {currentTransaction.loan_product.name}
          </span>
        </h5>
      );
    } else if(currentTransaction.record_type == "SAVINGS") {
      return (
        <h5>
          Savings Deposit
        </h5>
      );
    } else if(currentTransaction.record_type == "INSURANCE") {
      return (
        <h5>
          Insurance: &nbsp;
          <span className="text-muted">
            {currentTransaction.account_subtype} 
          </span>
        </h5>
      );
    } else if(currentTransaction.record_type == "WP") {
      return (
        <h5>
          Withdraw Payment
        </h5>
      );
    } else {
      return (
        <div>
        </div>
      );
    }
  }

  handleModalConfirm() {
    var currentTransaction  = this.state.currentTransaction;
    var currentMember       = this.state.currentMember;
    var context             = this;

    var data  = {
      current_transaction: currentTransaction,
      current_member: currentMember,
      id: this.props.id,
      authenticity_token: this.props.authenticityToken
    };

    this.setState({
      isLoading: true
    });

/*
    this.props.handleChangeTransaction(currentMember, currentTransaction, this.state.currentAmountValue);

    context.setState({
      currentTransaction: false,
      currentAmountValue: false,
      currentMember: false,
      modalIsOpen: false,
      isLoading: false,
      errors: false
    });
*/
    
    $.ajax({
      url: "/api/v1/billings/modify_transaction_record",
      method: "POST",
      data: data,
      success: function(response) {
        //window.location.reload();
        context.setState({
          currentTransaction: false,
          currentAmountValue: false,
          currentMember: false,
          modalIsOpen: false,
          isLoading: false,
          errors: false
        });

        context.props.updateData(response);
      },
      error: function(response) {
        try {
          var errors  = JSON.parse(response.responseText).errors;

          context.setState({
            isLoading: false,
            errors: errors
          });
        } catch(err) {
          console.log(response);
          alert("Something went wrong!");
          context.setState({
            isLoading: false
          });
        }
      }
    });
  }

  renderLoadingStatus() {
    if(this.state.isLoading) {
      return  (
        <div className="callout callout-info">
          Loading...
        </div>
      );
    } else if(this.state.errors) {
      return (
        <ErrorDisplay
          errors={this.state.errors}
        />
      );
    }
  }

  renderModalContent() {
    var currentTransaction  = this.state.currentTransaction;
    var currentMember       = this.state.currentMember;

    if(currentTransaction) {
      return (
        <div className="container">
          <div className="row">
            <div className="col">
              <h5>
                Member: &nbsp;
                <span className="text-muted">
                  {currentMember.full_name}
                </span>
              </h5>
              <h5>
                Transaction Type:  &nbsp;
                <span className="text-muted">
                  {currentTransaction.record_type}
                </span>
              </h5>
              {this.renderTransactionParticular()}

              <hr/>

              <input
                type="number"
                className="form-control"
                value={currentTransaction.amount}
                disabled={this.state.isLoading}
                onChange={this.handleInputAmountChanged.bind(this)}
              />

              {this.renderLoadingStatus()}
            </div>
          </div>
          <hr/>
          <div className="row">
            <div className="col">
              <center>
                <div className="btn-group">
                  <button 
                    className="btn btn-success" 
                    onClick={this.handleModalConfirm.bind(this)}
                    disabled={this.state.isLoading}
                  >
                    <span className="fa fa-check" />
                    Confirm Change
                  </button>

                  <button 
                    className="btn btn-danger" 
                    onClick={this.handleModalClose.bind(this)}
                    disabled={this.state.isLoading}
                  >
                    <span className="fa fa-times" />
                    Cancel Change
                  </button>
                </div>
              </center>
            </div>
          </div>
        </div>
      );
    } else {
      return (
        <div>
          Internal Error
        </div>
      );
    }
  }

  render() {
    return (
      <div className="table-responsive">
        <Modal
          isOpen={this.state.modalIsOpen}
          style={customStyles}
        >
          {this.renderModalContent()}
        </Modal>
        <table className="table table-bordered table-hover table-sm">
          <thead>
            <tr>
              {this.buildHeaders()}
            </tr>
          </thead>
          <tbody>
            {this.buildRecords()}
          </tbody>
          <tfoot>
            {this.buildTotals()}
          </tfoot>
        </table>
      </div>
    );
  }
}
