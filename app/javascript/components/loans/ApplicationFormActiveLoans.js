
import React from "react";
import $ from 'jquery';
import Modal from 'react-modal';
import { customEntryStyle } from "../utils/consts";

export default class ApplicationFormActiveLoans extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selectedLoanId: "",
      addedLoans: [],
      showTable: false,
      activeLoansCount: 0,
      activeLoans: [],
      showEditModal: false,
      loanEditAmount: 0,
      loanEditIndex: null,
      loanEditId: null,
    };

    this.handleActiveLoanChanged = this.handleActiveLoanChanged.bind(this);
    this.handleAddClick = this.handleAddClick.bind(this);
    this.fetchActiveLoans = this.fetchActiveLoans.bind(this);
  }

  // componentDidMount() {
  //   if (this.props.paidLoans && this.props.paidLoans.length > 0) {
  //     this.setState(
  //       {
  //         addedLoans: this.props.paidLoans,
  //         showTable: true
  //       },
  //       () => {
  //         this.handleActivePaidLoan();
  //         console.log("Paid Loans on Mount (Child):", this.state.addedLoans);
  //       }
  //     );
  //   }
  //   this.fetchActiveLoans();
  // }
componentDidMount() {
  if (this.props.paidLoans && this.props.paidLoans.length > 0) {
    // Map the paidLoans to ensure amountPaid defaults to principal if not set
    const mappedLoans = this.props.paidLoans.map(loan => {
      const principal = Number(loan.principal_balance || 0);
      return {
        ...loan,
        amountPaid: loan.amountPaid != null ? Number(loan.amountPaid) : principal
      };
    });

    this.setState({
      addedLoans: mappedLoans,
      showTable: true
    }, () => {
      this.handleActivePaidLoan();
      console.log("Paid Loans on Mount (Child):", this.state.addedLoans);
    });
  }

  this.fetchActiveLoans();
}

  componentDidUpdate(prevProps, prevState) {
    if (prevState.addedLoans !== this.state.addedLoans) {
      if (this.props.onPaidLoansExtracted) {
        this.props.onPaidLoansExtracted(this.handleActivePaidLoan());
      }
    }
  }

  fetchActiveLoans() {
    const context = this;
    $.ajax({
      url: "/loans/active_loans",
      data: { member_id: this.props.memberId },
      method: "GET",
      success: function (response) {
        if (response.message === "ok") {
          context.setState({
            activeLoansCount: response.count,
            activeLoans: response.loans
          });
        } else {
          console.warn(response.message);
        }
      }
    });
  }

  handleAddClick() {
    const { selectedLoanId, addedLoans, activeLoans } = this.state;

    const selectedLoan = activeLoans.find(loan => loan.loan_product_id === selectedLoanId);
    if (!selectedLoan) {
      alert("Loan not found.");
      return;
    }

    if (addedLoans.some(loan => loan.loan_product_id === selectedLoan.loan_product_id)) {
      alert("This loan has already been added.");
      return;
    }

    const updatedLoans = [...addedLoans, selectedLoan];

    this.setState({
      addedLoans: updatedLoans,
      selectedLoanId: "",
      showTable: true,
    }, () => {
      this.handleActivePaidLoan();
    });
  }

  handleActiveLoanChanged(event) {
    this.setState({ selectedLoanId: event.target.value });
  }

  // handleActivePaidLoan() {
  //   const { addedLoans } = this.state;

  //   const paidLoans = addedLoans.map((loan) => {
  //     const principal = Number(loan.principal_balance || 0);
  //     const interest = Number(loan.interest_balance || 0);
  //     const totalBalance = principal + interest;

  //     // Default totalPaid is principal if amountPaid not set
  //     const totalPaid = loan.amountPaid != null ? Number(loan.amountPaid) : principal;

  //     return {
  //       ...loan,
  //       total_balance: totalBalance,
  //       total_paid: totalPaid,
  //       amountPaid: totalPaid
  //     };
  //   });

  //   if (this.props.onPaidLoansExtracted) {
  //     this.props.onPaidLoansExtracted(paidLoans);
  //   }

  //   return paidLoans;
  // }
handleActivePaidLoan() {
  const { addedLoans } = this.state;

  const paidLoans = addedLoans.map((loan) => {
    const principal = Number(loan.principal_balance || 0);
    const interest = Number(loan.interest_balance || 0);
    const totalBalance = principal + interest;

    const totalPaid = loan.amountPaid != null ? Number(loan.amountPaid) : principal;

    return {
      ...loan,
      total_balance: totalBalance,
      total_paid: totalPaid,
      amountPaid: totalPaid
    };
  });

  if (this.props.onPaidLoansExtracted) {
    this.props.onPaidLoansExtracted(paidLoans);
  }

  return paidLoans;
}

  TotalPaid() {
    const { addedLoans } = this.state;

    const totalPrincipal = addedLoans.reduce((sum, loan) => sum + Number(loan.principal_balance || 0), 0);
    const totalInterest = addedLoans.reduce((sum, loan) => sum + Number(loan.interest_balance || 0), 0);
    const totalBalance = totalPrincipal + totalInterest;

    const totalAmountPaid = addedLoans.reduce((sum, loan) => {
      return sum + (loan.amountPaid != null ? Number(loan.amountPaid) : Number(loan.principal_balance || 0));
    }, 0);

    return {
      totalPrincipal,
      totalInterest,
      totalBalance,
      totalAmountPaid
    };
  }

  handleEditClick(loan, index) {
    this.setState({
      showEditModal: true,
      loanEditIndex: index,
      loanEditId: loan.loan_product_id,
      loanEditAmount: loan.amountPaid != null ? loan.amountPaid : Number(loan.principal_balance || 0),
    });
  }

  handleCancelEdit() {
    if (window.confirm("Are you sure you want to cancel?")) {
      this.setState({
        showEditModal: false,
      });
    }
  }

  handleSaveEdit() {
    const { addedLoans, loanEditIndex, loanEditAmount } = this.state;
    const updatedLoans = [...addedLoans];
    updatedLoans[loanEditIndex].amountPaid = Number(loanEditAmount);

    this.setState({
      addedLoans: updatedLoans,
      showEditModal: false,
      loanEditIndex: null,
      loanEditId: null,
      loanEditAmount: 0,
    }, () => {
      alert("Edit saved successfully!");
      this.handleActivePaidLoan();
    });
  }

  renderEditBalance() {
    return (
      <div className="container-fluid">
        <h3>Edit total paid</h3>
        <hr />
        <div className="form-group">
          <label>Amount</label>
          <input
            type="number"
            className="form-control"
            value={this.state.loanEditAmount}
            onChange={(e) => this.setState({ loanEditAmount: e.target.value })}
          />
          <div className="d-flex justify-content-end gap-3 mt-3">
            <button
              className="btn btn-success"
              onClick={() => this.handleSaveEdit()}
            >
              <span className="bi bi-check me-2" />
              Save
            </button>
            <button
              className="btn btn-danger"
              onClick={() => this.handleCancelEdit()}
            >
              <span className="bi bi-x me-2" />
              Cancel
            </button>
          </div>
        </div>
      </div>
    );
  }

  render() {
    const { addedLoans, showTable, activeLoans, selectedLoanId } = this.state;
    const { totalPrincipal, totalInterest, totalBalance, totalAmountPaid } = this.TotalPaid();

    const formatNumber = (value) =>
      Number(value)
        .toFixed(2)
        .replace(/\B(?=(\d{3})+(?!\d))/g, ",");

    const ActiveLoansCategoryOptions = [
      <option key="default" value="">
        -- SELECT --
      </option>,
      ...activeLoans
        .map(loan => (
          <option key={loan.loan_product_id} value={loan.loan_product_id}>
            {loan.loan_product?.name || loan.loan_product_name || loan.loan_product_id}
          </option>
        )),
    ];

    return (
      <div>
        <Modal
          isOpen={this.state.showEditModal}
          style={customEntryStyle}
        >
          {this.renderEditBalance()}
        </Modal>

        <div className="row">
          <div className="col">
            <div className="form-group">
              <label>Loan</label>
              <div className="d-flex">
                <select
                  onChange={this.handleActiveLoanChanged}
                  className="form-control me-3"
                  disabled={this.props.disabled}
                  value={selectedLoanId}
                >
                  {ActiveLoansCategoryOptions}
                </select>
                <button
                  type="button"
                  onClick={this.handleAddClick}
                  className="btn btn-success"
                >
                  Add
                </button>
              </div>
            </div>
          </div>
        </div>

        {showTable && addedLoans.length > 0 && (
          <table className="table table-bordered mt-3">
            <thead className="text-center">
              <tr>
                <th>Loan Name</th>
                <th>Principal Balance</th>
                <th>Interest Balance</th>
                <th>Total Balance</th>
                <th>Total Paid</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {addedLoans.map((loan, index) => {
                const principal = Number(loan.principal_balance || 0);
                const interest = Number(loan.interest_balance || 0);
                const totalBalance = principal + interest;
                const totalPaid = loan.amountPaid != null ? loan.amountPaid : principal;

                return (
                  <tr key={loan.loan_product_id}>
                    <td>{loan.loan_product?.name || loan.loan_product_name || loan.loan_product_id}</td>
                    <td className="text-end">{formatNumber(principal)}</td>
                    <td className="text-end">{formatNumber(interest)}</td>
                    <td className="text-end">{formatNumber(totalBalance)}</td>
                    <td className="text-end">{formatNumber(totalPaid)}</td>
                    <td className="text-center">
                      <button
                        className="btn btn-sm btn-primary"
                        onClick={() => this.handleEditClick(loan, index)}
                      >
                        <span className="bi bi-pencil-fill me-2" />
                        Edit
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
            <tfoot>
              <tr className="fw-bold">
                <td>Total</td>
                <td className="text-end">{formatNumber(totalPrincipal)}</td>
                <td className="text-end">{formatNumber(totalInterest)}</td>
                <td className="text-end">{formatNumber(totalBalance)}</td>
                <td className="text-end">{formatNumber(totalAmountPaid)}</td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        )}
      </div>
    );
  }
}
