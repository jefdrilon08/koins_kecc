import React from 'react';
import axios from 'axios';
import {numberWithCommas} from '../utils/helpers';
import { Modal, Button, Form } from 'react-bootstrap';
import Select from 'react-select';

export default class AccountingEntryPreview extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      showCodeModal: false, // Controls visibility of accounting code modal
      showAmountModal: false, // Controls visibility of amount modal
      selectedEntry: null, // Stores the selected journal entry
      selectedAccountingCode: '', // Stores selected accounting code value
      newSelectedAccountingCode: '', // Stores the NEW selection from dropdown
      selectedAmount: '', // Stores selected amount value
      loanId: this.props.id,
      isSubmitting: false,
    };
  }

  // Opens the modal for editing accounting code
  handleCodeClick = (entry) => {
    console.log("Selected Entry:", entry);
    this.setState({
      showCodeModal: true,
      selectedEntry: entry,
      selectedAccountingCode: entry.accounting_code_name,
      newSelectedAccountingCode: ''

    });
  };

  handleAmountClick = (entry) => {
    const amountWithDecimals = parseFloat(entry.amount).toFixed(2);
  
    this.setState({
      showAmountModal: true,
      selectedEntry: entry,
      selectedAmount: amountWithDecimals,
    });
  };
  

  // Closes both modals
  handleCloseModals = () => {
    this.setState({
      showCodeModal: false,
      showAmountModal: false,
      selectedEntry: null
    });
  };

  // Updates the selected accounting code value
  handleAccountingCodeChange = (event) => {
    this.setState({ newSelectedAccountingCode: event.target.value });
  };

  handleSaveAccountingCode = () => {
    const { selectedEntry, newSelectedAccountingCode, loanId, isSubmitting } = this.state;

    if (isSubmitting) return;
  
    if (!selectedEntry || !newSelectedAccountingCode) {
      alert("Please select a new accounting code.");
      return;
    }
  
    if (newSelectedAccountingCode === String(selectedEntry.accounting_code_id)) {
      alert("No changes detected.");
      return;
    }
  
    const selectedCodeObj = this.props.accountingCodes.find(
      (code) => String(code.id) === newSelectedAccountingCode
    );
    
    if (!selectedCodeObj) {
      console.error("Invalid accounting code selected.");
      return;
    }

    this.setState({ isSubmitting: true });
  
    const requestData = {
      loan_id: loanId,
      accounting_code_id: selectedEntry.accounting_code_id,
      accounting_code_new: selectedCodeObj.id,
    };
  
    const authenticityToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
  
    axios.post("/api/v1/loans/edit_accounting_name",
      requestData,
      {
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": authenticityToken
        }
      }
    )
    .then(response => {
      console.log("Accounting code updated:", response.data);
      alert("Accounting code updated successfully.");
      this.setState({ showCodeModal: false, isSubmitting: false });
      window.location.reload();
    })
    .catch(error => {
      console.error("Failed to update accounting code:", error);
      alert("Error saving accounting code. Please try again.");
      this.setState({ isSubmitting: false });
    });
  };
  

  // Updates the selected amount value
  handleAmountChange = (event) => {
    this.setState({ selectedAmount: event.target.value });
  };

  handleSaveAmount = () => {
    const { selectedAmount, selectedEntry, loanId, isSubmitting} = this.state;

    if (isSubmitting) return;
    
    if (!selectedEntry) {
      alert("No entry selected.");
      return;
    }
  
    let amount = parseFloat(selectedAmount);

    if (isNaN(amount) || amount <= 0) {
      alert("Amount must be a valid number greater than 0.");
    return;
    }

    const originalAmount = parseFloat(selectedEntry.amount);
    if (amount === originalAmount) {
      alert("No changes detected.");
      return;
    }

    this.setState({ isSubmitting: true });

    const requestData = {
      loan_id: loanId,
      accounting_code_id: selectedEntry.accounting_code_id,
      amount: parseFloat(amount.toFixed(2))
    }

    const authenticityToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
  
    axios.post("/api/v1/loans/edit_entry_amount", 
      requestData,
      {
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": authenticityToken
        },
      }
    )
    .then(response => {
      console.log("Amount updated:", response.data);
      alert("Amount updated successfully.");
      this.setState({ showAmountModal: false });
      window.location.reload();
    })
    .catch(error => {
      console.error("Failed to update amount:", error);
      alert("Error saving amount. Please try again.");
      this.setState({ isSubmitting: false });
    });
  };

  accountingEntryContextColor() {
    if(this.props.book == "CRB") {
      return "bg-success";
    } else if(this.props.book == "CDB") {
      return "bg-warning";
    } else if(this.props.book == "JVB") {
      return "bg-info";
    } else {
      return "bg-info";
    }
  }

  renderCrbParameters() {
    if(this.props.book == "CRB") {
      return (
        <div>
          <hr/>
          <strong>
            OR Number: 
          </strong>
          <br/>
          <span className="text-muted">
            {this.props.data.or_number}
          </span>
          <br/>
          <strong>
            Service Invoice: 
          </strong>
          <br/>
          <span className="text-muted">
            {this.props.data.si_number}
          </span>
          <br/>
          <strong>
            AR Number: 
          </strong>
          <br/>
          <span className="text-muted">
            {this.props.data.ar_number}
          </span>
        </div>
      );
    }
  };

  renderCdbParameters() {
    console.log("CDB Parameters: ");
    console.log(this.props);
    if(this.props.book == "CDB") {
      return (
        <div className="row">
          <div className="col">
            <strong>
              Check Number:
            </strong>
            <div className="text-muted">
              {this.props.data.check_number}
            </div>
          </div>
          <div className="col">
            <strong>
              Check Voucher Number:
            </strong>
            <div className="text-muted">
              {this.props.data.check_voucher_number}
            </div>
          </div>
          <div className="col">
            <strong>
              Date of Check
            </strong>
            <div className="text-muted">
              {this.props.data.date_of_check}
            </div>
          </div>
        </div>
      );
    }
  };

  renderBalancedWarning() {
    var debitAmount   = 0.00;
    var creditAmount  = 0.00;

    for(var i = 0; i < this.props.journalEntries.length; i++) {
      if(this.props.journalEntries[i].post_type == "DR") {
        debitAmount += parseFloat(this.props.journalEntries[i].amount);
      } else if(this.props.journalEntries[i].post_type == "CR") {
        creditAmount += parseFloat(this.props.journalEntries[i].amount);
      }
    }

    if(!this.props.balanced) {
      return (
        <div className="callout callout-danger">
          <strong>
            Entries are not balanced.. Debit: {numberWithCommas(debitAmount)} Credit: {numberWithCommas(creditAmount)}
          </strong>
        </div>
      );
    }
  }

  render() {
    var context = this;
    var journalEntryRecords = [];

    const isPending = this.props.loanstatus === "pending";

    console.log("Is Pending:", isPending, "Loan Status:", this.props.loanstatus);

    const codeOptions = (this.props.accountingCodes || []).map(c => ({
      value: String(c.id),
      label: `${c.code} - ${c.name}`
    }));
    const currentCodeOption =
      codeOptions.find(o => o.value === String(this.state.newSelectedAccountingCode)) || null;

    // Debit entries
    for(var i = 0; i < this.props.journalEntries.length; i++) {
      const entry = this.props.journalEntries[i];

      if (entry.post_type == "DR" && entry.amount > 0) {
        var btnRemove = "";
        var btnEdit   = "";

        if(this.props.status == "pending") {
          btnRemove = <button 
                        className="btn btn-sm btn-danger"
                        onClick={context.props.handleRemoveClicked.bind(this, i)}
                      >
                        <span className="bi bi-x"/>
                      </button>;

          btnEdit = <button
                      className="btn btn-sm btn-info"
                      onClick={context.props.handleJournalEntryEdit.bind(this, i)}
                    >
                      <span className="bi bi-pencil"/>
                    </button>
        }

        journalEntryRecords.push(
          <tr key={"je-dr-" + i}>
            <td>
              {btnEdit}
              {btnRemove}
              {isPending ? (
                <button className="btn btn-link p-0 text-primary text-decoration-none" 
                  onClick={() => this.handleCodeClick(entry)}
                >
                  {entry.accounting_code_name}
                </button>
              ) : (
                <span>{entry.accounting_code_name}</span>
              )}
            </td>
            <td className="text-end">
              {isPending ? (
                <button className="btn btn-link p-0 text-primary text-decoration-none" 
                  onClick={() => this.handleAmountClick(entry)}
                >
                  {numberWithCommas(entry.amount)}
                </button>
              ) : (
                <span>{numberWithCommas(entry.amount)}</span>
              )}
            </td>
            <td className="text-end">
            </td>
          </tr>
        );
      }
    }

    // Credit entries
    for(var i = 0; i < this.props.journalEntries.length; i++) {
      const entry = this.props.journalEntries[i];
      
      if (entry.post_type == "CR" && entry.amount > 0) {
        var btnRemove = "";
        var btnEdit   = "";

        if(this.props.status == "pending") {
          btnRemove = <button 
                        className="btn btn-sm btn-danger"
                        onClick={context.props.handleRemoveClicked.bind(this, i)}
                      >
                        <span className="bi bi-x"/>
                      </button>;

          btnEdit = <button
                      className="btn btn-sm btn-info"
                      onClick={context.props.handleJournalEntryEdit.bind(this, i)}
                    >
                      <span className="bi bi-pencil"/>
                    </button>
        }

        journalEntryRecords.push(
          <tr key={"je-cr-" + i}>
            <td>
              {btnEdit}
              {btnRemove}
              {isPending ? (
              <button className="btn btn-link p-0 text-primary text-decoration-none" 
                onClick={() => this.handleCodeClick(entry)}
              >
                {entry.accounting_code_name}
              </button>
            ) : (
              <span>{entry.accounting_code_name}</span>
            )}
            </td>
            <td className="text-end">
            </td>
            <td className="text-end">
            {isPending ? (
              <button className="btn btn-link p-0 text-primary text-decoration-none" 
                      onClick={() => this.handleAmountClick(entry)} 
              >
                {numberWithCommas(entry.amount)}
              </button>
            ) : (
              <span>{numberWithCommas(entry.amount)}</span> // Non-clickable
            )}
            </td>
          </tr>
        );
      }
    }

    return  (
      <div className="card border-danger">
        <div className={"card-header " + this.accountingEntryContextColor()}>
          <div className="row">
            <div className="col-md-6">
              <strong>
                {this.props.book} {this.props.referenceNumber} - {this.props.datePosted}
              </strong>
            </div>
            <div className="col-md-6">
              <div className="text-end">
                <div className="text-muted">
                  <span className="fa fa-store"/>
                  {this.props.branch}
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="card-body">
          {this.renderBalancedWarning()}
          <table className="table table-sm">
            <thead>
              <tr>
                <th width="50%">
                  Accounting Code
                </th>
                <th className="text-end" width="25%">
                  Debit
                </th>
                <th className="text-end" width="25%">
                  Credit
                </th>
              </tr>
            </thead>
            <tbody>
              {journalEntryRecords}
            </tbody>
          </table>
          <hr/>
          <div className="row">
            <div className="col">
              <label>
                Particular:
              </label>
              <p>
                {this.props.particular}
              </p>
            </div>
            <div className="col">
              <p className="text-end">
                <label>
                  <strong>
                    Approved By:
                  </strong>
                </label>
                <br/>
                {this.props.approved_by}
              </p>
            </div>
          </div>
          {this.renderCrbParameters()}
          {this.renderCdbParameters()}
        </div>
        <Modal show={this.state.showCodeModal} onHide={this.handleCloseModals}>
        <Modal.Header closeButton>
          <Modal.Title>Edit Accounting Code</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form>
            <Form.Group>
              <Form.Label>Accounting Code Name</Form.Label>
              {/* Textbox for manual input */}
              <Form.Control
                type="text"
                value={this.state.selectedAccountingCode}
                //  onChange={this.handleAccountingCodeChange}
                readOnly
              />
            </Form.Group>
            <Form.Group>
              <Form.Label>Select New Accounting Code</Form.Label>
              {/* Dropdown for selecting accounting code */}
              <Select
                inputId="select-accounting-code"
                options={codeOptions}
                value={currentCodeOption}
                onChange={(opt) =>
                  this.setState({ newSelectedAccountingCode: opt ? opt.value : '' })
                }
                isClearable
                placeholder="Search code or name…"
                // keep menu visible above Bootstrap modal
                menuPortalTarget={typeof document !== 'undefined' ? document.body : null}
                styles={{ menuPortal: (base) => ({ ...base, zIndex: 9999 }) }}
                // optional: case-insensitive match (react-select already searches label)
                filterOption={(option, input) =>
                  option.label.toLowerCase().includes(input.toLowerCase())
                }
              />
            </Form.Group>
          </Form>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={this.handleCloseModals}>Close</Button>
          <Button variant="primary" onClick={this.handleSaveAccountingCode} disabled={
            this.state.isSubmitting || 
            !this.state.newSelectedAccountingCode || 
            this.state.newSelectedAccountingCode === String(this.state.selectedEntry?.accounting_code_id)
            }
          >
            Save
          </Button>
        </Modal.Footer>
      </Modal>

      <Modal show={this.state.showAmountModal} onHide={this.handleCloseModals}>
        <Modal.Header closeButton>
          <Modal.Title>Edit Amount</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form>
            <Form.Group>
              <Form.Label>Amount</Form.Label>
              {/* Textbox for numeric input */}
              <Form.Control
                id="input-accounting-amount"
                type="number"
                min="0.01"
                step="0.01"
                value={this.state.selectedAmount}
                onChange={this.handleAmountChange}
              />
            </Form.Group>
          </Form>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={this.handleCloseModals}>Close</Button>
          <Button variant="primary" onClick={this.handleSaveAmount} disabled={
            this.state.isSubmitting || 
            parseFloat(this.state.selectedAmount) === parseFloat(this.state.selectedEntry?.amount)
            }
          >
            Save
          </Button>
        </Modal.Footer>
      </Modal>
      </div>
    );
  }
}