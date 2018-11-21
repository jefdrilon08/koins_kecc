import React from 'react';
import Modal from 'react-modal';

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

Modal.setAppElement("#survey-content")

export default class ModalSurveyName extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      name: this.props.data.name
    };
  }
  
  handleNameChanged(event) {
    this.setState({
      name: event.target.value
    });
  }

  handleSaveClicked() {
    var name  = this.state.name;
    var data  = this.props.data;

    data.name = name;

    this.props.updateData(data);
  }

  handleCancelClicked() {
    this.setState({
      name: this.props.data.name
    });

    this.props.closeSurveyNameModal();
  }

  render() {
    return  (
      <Modal
        isOpen={this.props.modalSurveyNameIsOpen}
        style={customStyles}
      >
        <div className="container">
          <div className="row">
            <div className="col">
              <div className="form-group">
                <label>
                  Survey Name:
                </label>
                <input
                  type="text"
                  className="form-control"
                  value={this.state.name}
                  onChange={this.handleNameChanged.bind(this)}
                />
                <hr/>
                <div className="btn-group">
                  <center>
                    <button
                      className="btn btn-success"
                      onClick={this.handleSaveClicked.bind(this)}
                    >
                      <span className="fa fa-check"/>
                      Save
                    </button>
                    <button
                      className="btn btn-danger"
                      onClick={this.handleCancelClicked.bind(this)}
                    >
                      <span className="fa fa-times"/>
                      Cancel
                    </button>
                  </center>
                </div>
              </div>
            </div>
          </div>
        </div>
      </Modal>
    );
  }
}
