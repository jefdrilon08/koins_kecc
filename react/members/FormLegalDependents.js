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

export default class FormLegalDependents extends React.Component {
  constructor(props) {
    super(props);
    
    this.state  = {
      modalIsOpen: false,
      currentLegalDependent: {
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
    }
  }

  validateCurrentLegalDependent() {
    var o       = this.state.currentLegalDependent;
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
      currentLegalDependent: {
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
      currentLegalDependent: {
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

    this.validateCurrentLegalDependent();

    if(this.state.errors.length == 0) {
      this.props.updateData(data);

      this.setState({
        modalIsOpen: false,
        currentLegalDependent: {
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
    var currentLegalDependent = this.state.currentLegalDependent;

    currentLegalDependent.first_name  = event.target.value.toUpperCase();

    this.setState({
      currentLegalDependent: currentLegalDependent
    });
  }

  handleMiddleNameChanged(event) {
    var currentLegalDependent = this.state.currentLegalDependent;

    currentLegalDependent.middle_name  = event.target.value.toUpperCase();

    this.setState({
      currentLegalDependent: currentLegalDependent
    });
  }

  handleLastNameChanged(event) {
    var currentLegalDependent = this.state.currentLegalDependent;

    currentLegalDependent.last_name  = event.target.value.toUpperCase();

    this.setState({
      currentLegalDependent: currentLegalDependent
    });
  }

  handleDateOfBirthChanged(event) {
    var currentLegalDependent = this.state.currentLegalDependent;

    currentLegalDependent.date_of_birth  = event.target.value;

    this.setState({
      currentLegalDependent: currentLegalDependent
    });
  }

  handleRelationshipChanged(event) {
    var currentLegalDependent = this.state.currentLegalDependent;

    currentLegalDependent.relationship  = event.target.value;

    this.setState({
      currentLegalDependent: currentLegalDependent
    });
  }

  handleEducationalAttainmentChanged(event) {
    var currentLegalDependent = this.state.currentLegalDependent;

    currentLegalDependent.data.educational_attainment = event.target.value;

    this.setState({
      currentLegalDependent: currentLegalDependent
    });
  }

  handleCourseChanged(event) {
    var currentLegalDependent = this.state.currentLegalDependent;

    currentLegalDependent.course  = event.target.value.toUpperCase();

    this.setState({
      currentLegalDependent: currentLegalDependent
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
            Legal Dependent Form
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
                <label>Antas ng Pag-aaral</label>
                <select
                  className="form-control"
                >
                  <option value="elementary">Elementary</option>
                  <option value="high school">High School</option>
                  <option value="college">College</option>
                </select>
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>Kurso</label>
                <input
                  className="form-control"
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>Relasyon</label>
                <select
                  className="form-control"
                >
                  <option value="Child">Child</option>
                  <option value="Spouse">Spouse</option>
                  <option value="Parent">Parent</option>
                </select>
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
