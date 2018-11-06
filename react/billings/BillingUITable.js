import React from 'react';
import ReactTable from 'react-table';
import Modal from 'react-modal';

import 'react-table/react-table.css';

import {numberWithCommas} from '../utils/helpers';

const customStyles = {
  content : {
    top                   : '50%',
    left                  : '50%',
    right                 : 'auto',
    bottom                : 'auto',
    marginRight           : '-50%',
    transform             : 'translate(-50%, -50%)'
  }
};

Modal.setAppElement("#billing-content")

export default class BillingUITable extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      currentTransaction: false,
      currentAmountValue: false,
      currentMember: false,
      modalIsOpen: false,
      isLoading: false
    };
  }

  buildHeaders() {
    var headers = [];

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
      <th  key={"h-total"} style={{minWidth: "100px"}}>
        <center>
          TOTAL
        </center>
      </th>
    );

    return headers;
  }


  buildRecords() {
    var records = [];

    for(var i = 0; i < this.props.data.data.records.length; i++) {
      var components  = [];
      var member      = this.props.data.data.records[i].member;

      components.push(
        <td key={"c-member-" + member.id}>
          <strong>
            <a href={"/members/" + member.id + "/display"} target="_blank">
              {this.props.data.data.records[i].member.full_name}
            </a>
          </strong>
        </td>
      );

      for(var j = 0; j < this.props.data.data.records[i].records.length; j++) {
        var paymentRecord = this.props.data.data.records[i].records[j];
        if(paymentRecord.record_type == "LOAN_PAYMENT" && paymentRecord.enabled == true) {
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
        } else if(paymentRecord.record_type == "SAVINGS" && paymentRecord.enabled == true) {
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
        } else if(paymentRecord.record_type == "INSURANCE" && paymentRecord.enabled == true) {
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
        } else if(paymentRecord.record_type == "WP" && paymentRecord.enabled == true) {
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

      records.push(
        <tr key={"member-row-" + i}>
          {components}
        </tr>
      );
    }

    return records;
  }

  buildTotals() {
    var records = [];

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
        records.push(
          <td key={"total-loan-payment-" + totals[i].key} className="text-right">
            <strong>
              {numberWithCommas(totals[i].amount)}
            </strong>
          </td>
        );
      } else if(totals[i].record_type == "SAVINGS") {
        records.push(
          <td key={"total-savings-" + totals[i].key} className="text-right">
            <strong>
              {numberWithCommas(totals[i].amount)}
            </strong>
          </td>
        );
      } else if(totals[i].record_type == "INSURANCE") {
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

    return (
      <tr>
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
      currentAmountValue: false
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
            </div>
          </div>
          <hr/>
          <div className="row">
            <div className="col">
              <center>
                <div className="btn-group">
                  <button className="btn btn-success">
                    <span className="fa fa-check" />
                    Confirm Change
                  </button>

                  <button className="btn btn-danger" onClick={this.handleModalClose.bind(this)}>
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
