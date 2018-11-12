import React from "react";

import Modal from 'react-modal';

Modal.setAppElement("body");

const customStyles  = {
  content : {
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -50%)'
  }
}

export default class FormBeneficiaries extends React.Component {
  constructor(props) {
    super(props);
    
    this.state  = {
      modalIsOpen: false,
      currentBeneficiary: {
        id: "",
        first_name: "",
        middle_name: "",
        last_name: "",
        date_of_birth: "",
        relationship: ""
      }
    }
  }

  validateCurrentBeneficiary() {
    var o       = this.state.currentBeneficiary;
    var errors  = [];

    if(!o.first_name) {
      errors.push("first name required");
    }

    if(!o.last_name) {
      errors.push("last name required");
    }

    if(!o.date_of_birth) {
      errors.push("date of birth required");
    }

    this.setState({
      errors: errors
    });
  }

  handleCancelClicked() {
    this.setState({
      modalIsOpen: false,
      currentBeneficiary: {
        id: "",
        first_name: "",
        middle_name: "",
        last_name: "",
        date_of_birth: "",
        relationship: "",
        data: {
          educational_attainment: "",
          course: ""
        }
      }
    });
  }

  handleDeleteClicked(index) {
    var data  = this.props.data;

    data.legal_dependents.splice(index);

    this.props.updateData(data);
  };

  handleAddClicked() {
    this.setState({
      modalIsOpen: true,
      currentBeneficiary: {
        id: "",
        first_name: "",
        middle_name: "",
        last_name: "",
        date_of_birth: "",
        relationship: "",
        data: {
          educational_attainment: "",
          course: ""
        }
      }
    });
  }

  handleConfirmSaveClicked() {
    var data  = this.props.data;

    this.validateCurrentBeneficiary();

    if(this.state.errors.length == 0) {
      this.props.updateData(data);

      this.setState({
        modalIsOpen: false,
        currentBeneficiary: {
          id: "",
          first_name: "",
          middle_name: "",
          last_name: "",
          date_of_birth: "",
          relationship: "",
          data: {
            educational_attainment: "",
            course: ""
          }
        }
      });
    }
  };

  handleFirstNameChanged(event) {
    var currentBeneficiary = this.state.currentBeneficiary;

    currentBeneficiary.first_name  = event.target.value.toUpperCase();

    this.setState({
      currentBeneficiary: currentBeneficiary
    });
  }

  handleMiddleNameChanged(event) {
    var currentBeneficiary = this.state.currentBeneficiary;

    currentBeneficiary.middle_name  = event.target.value.toUpperCase();

    this.setState({
      currentBeneficiary: currentBeneficiary
    });
  }

  handleLastNameChanged(event) {
    var currentBeneficiary = this.state.currentBeneficiary;

    currentBeneficiary.last_name  = event.target.value.toUpperCase();

    this.setState({
      currentBeneficiary: currentBeneficiary
    });
  }

  handleDateOfBirthChanged(event) {
    var currentBeneficiary = this.state.currentBeneficiary;

    currentBeneficiary.date_of_birth  = event.target.value;

    this.setState({
      currentBeneficiary: currentBeneficiary
    });
  }

  handleRelationshipChanged(event) {
    var currentBeneficiary = this.state.currentBeneficiary;

    currentBeneficiary.relationship  = event.target.value.toUpperCase();

    this.setState({
      currentBeneficiary: currentBeneficiary
    });
  }

  render() {
    return (
      <div>
        <Modal
          isOpen={this.state.modalIsOpen}
          style={customStyles}
        >
          <h3>
            Beneficiary Form
          </h3>
          <div className="row">
            <div className="col">
              <div className="form-group">
                <label>* Pangalan</label>
                <input
                  className="form-control"
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>Gitnang Pangalan</label>
                <input
                  className="form-control"
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>* Apelyido</label>
                <input
                  className="form-control"
                />
              </div>
            </div>
          </div>
          <div className="row">
            <div className="col">
              <div className="form-group">
                <label>* Kapanganakan</label>
                <input
                  className="form-control"
                  type="date"
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>Relasyon</label>
                <input
                  className="form-control"
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>Is Primary?</label>
                <input
                  type="checkbox"
                  className="form-control"
                />
              </div>
            </div>
          </div>
          <hr/>
          <center>
            <div className="btn-group">
              <button
                className="btn btn-primary"
                onClick={this.handleConfirmSaveClicked.bind(this)}
              >
                <span className="fa fa-check"/>
                Confirm
              </button>
              <button
                className="btn btn-danger"
                onClick={this.handleCancelClicked.bind(this)}
              >
                <span className="fa fa-times"/>
                Cancel
              </button>
            </div>
          </center>
        </Modal>

        <button
          className="btn btn-info btn-sm"
          onClick={this.handleAddClicked.bind(this)}
        >
          <span className="fa fa-plus"/>
          Add
        </button>
      </div>
    );
  }
}
