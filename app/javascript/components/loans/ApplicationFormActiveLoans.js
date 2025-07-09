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

  componentDidMount() {
    this.fetchActiveLoans();
  }

  fetchActiveLoans() {
    var context = this;
    $.ajax({
      url: "/loans/active_loans",
      data: {
        member_id: this.props.memberId
      },
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

  // handleAddClick() {
  //   const { selectedLoanId, addedLoans, activeLoans } = this.state;

  //   if (!selectedLoanId) return alert("Please select a loan first.");

  //   const selectedLoan = activeLoans.find(loan => loan.id === selectedLoanId);
  //   if (!selectedLoan) return alert("Loan not found.");
  //   if (addedLoans.some(loan => loan.id === selectedLoan.id))
  //     return alert("This loan has already been added.");

  //   this.setState({
  //     addedLoans: [...addedLoans, selectedLoan],
  //     selectedLoanId: "",
  //     showTable: true,
  //   });
  // }


  handleAddClick() {
  const { selectedLoanId, addedLoans, activeLoans } = this.state;

  if (!selectedLoanId) {
    alert("Please select a loan first.");
    return;
  }

  const selectedLoan = activeLoans.find(loan => loan.id === selectedLoanId);
  if (!selectedLoan) {
    alert("Loan not found.");
    return;
  }

  if (addedLoans.some(loan => loan.id === selectedLoan.id)) {
    alert("This loan has already been added.");
    return;
  }

  const updatedLoans = [...addedLoans, selectedLoan];

  this.setState({
    addedLoans: updatedLoans,
    selectedLoanId: "",
    showTable: true,
  }, () => {
    // ✅ Trigger loan data throw after state is updated
    this.handleActivePaidLoan();
  });
}


  handleActiveLoanChanged(event) {
    this.setState({ selectedLoanId: event.target.value });
  }

  TotalPaid() {
    const { addedLoans } = this.state;

    const totalPrincipal = addedLoans.reduce((sum, loan) => sum + Number(loan.principal_balance || 0), 0);
    const totalInterest = addedLoans.reduce((sum, loan) => sum + Number(loan.interest_balance || 0), 0);
    const totalBalance = totalPrincipal + totalInterest;
    const totalAmountPaid = addedLoans.reduce((sum, loan) => {
    const principal = Number(loan.principal_balance || 0);
    const interest = Number(loan.interest_balance || 0);
      return sum + (loan.amountPaid != null ? Number(loan.amountPaid) : principal + interest);
    }, 0);

    return {
      totalPrincipal,
      totalInterest,
      totalBalance,
      totalAmountPaid
    };
  }

  handleEditClick(loan, index) {
    const principal = Number(loan.principal_balance || 0);
    const interest = Number(loan.interest_balance || 0);
    const totalBalance = principal + interest;

    this.setState({
      showEditModal: true,
      loanEditIndex: index,
      loanEditId: loan.id,
      loanEditAmount: loan.amountPaid != null ? loan.amountPaid : totalBalance,
    });
  }

  handleCancelEdit() {
    if (window.confirm("Are you sure you want to cancel?")) {
      this.setState({
        showEditModal: false,
      });
    }
  }

  // handleSaveEdit() {
  //   const { addedLoans, loanEditIndex, loanEditAmount } = this.state;
  //   const updatedLoans = [...addedLoans];
  //   updatedLoans[loanEditIndex].amountPaid = Number(loanEditAmount);

  //   this.setState({
  //     addedLoans: updatedLoans,
  //     showEditModal: false,
  //     loanEditIndex: null,
  //     loanEditId: null,
  //     loanEditAmount: 0,
  //   }, () => {
  //     alert("Edit saved successfully!");
  //   });
  // }

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
    this.handleActivePaidLoan(); // ✅ auto-trigger
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


  // for rendering or throwing the data
handleActivePaidLoan() {
  const { addedLoans, activeLoans } = this.state;

//   if (addedLoans.length === 0) {
//     alert("Please add an active loan first.");
//     return;
//   }else {
//     alert("Active loan sucessfully added")
// }


  const paidLoans = addedLoans.map((loan) => {
    const principal = Number(loan.principal_paid || 0);
    const principalbal = Number(loan.principal_balance || 0);
    const interest = Number(loan.interest_balance || 0);
    const totalBalance = principalbal + interest;
    const totalPaid = loan.amountPaid != null ? Number(loan.amountPaid) : totalBalance;

    return {
      loan_product_id: loan.loan_product_id || loan.loan_product.id || "N/A",
      total_paid: totalPaid,
      interest_paid: totalPaid,
      principal_paid: principal,
      total_balance: totalBalance
    };
  });

   if (this.props.onPaidLoansExtracted) {
    this.props.onPaidLoansExtracted(paidLoans);
  }
  
  return paidLoans;
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
      ...activeLoans.map(loan => (
        <option key={loan.id} value={loan.id}>
          {loan.loan_product.name || "No Product Name"}
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
                const totalPaid = loan.amountPaid != null ? loan.amountPaid : totalBalance;

                return (
                  <tr key={loan.id}>
                    <td>{loan.loan_product.name}</td>
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
        <div className="d-flex justify-content-end">
      </div>
      </div>
    );
  }
}
