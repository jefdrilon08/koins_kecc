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

export default class FormAttachmentFiles extends React.Component {
  constructor(props) {
    super(props);
    
    this.state  = {
      modalIsOpen: false,
      errors: [],
      currentAttachmentFile: {
        name: "",
        attachment_file: "",
      }
    }
  }

  validateCurrentAttachmentFile() {
    var o       = this.state.currentAttachmentFile;
    var errors  = [];

    if(!o.attachment_file) {
      errors.push("attachment file required");
    }

    if(!o.name) {
      errors.push("name required");
    }

    this.setState({
      errors: errors
    });

    return errors;
  }

  handleCancelClicked() {
    this.setState({
      modalIsOpen: false,
      currentAttachmentFile: {
        name: "",
        attachment_file: ""
      }
    });
  }

  handleDeleteClicked(index) {
    var data  = this.props.data;

    data.attachment_files.splice(index, 1);

    this.props.updateData(data);
  };

  handleAddClicked() {
    this.setState({
      modalIsOpen: true,
      errors: [],
      currentAttachmentFile: {
        name: "",
        attachment_file: ""
      }
    });
  }

  handleConfirmSaveClicked() {
    var data    = this.props.data;
    var errors  = this.validateCurrentAttachmentFile();

    alert(data);
    if(errors.length == 0) {
      data.attachment_files.push(this.state.currentAttachmentFile);
      this.props.updateData(data);

      this.setState({
        modalIsOpen: false,
        currentAttachmentFile: {
          name: "",
          attachment_file: ""
        }
      });
    }
  };

  handleNameChanged(event) {
    var currentAttachmentFile = this.state.currentAttachmentFile;

    currentAttachmentFile.name = event.target.value;

    this.setState({
      currentAttachmentFile: currentAttachmentFile
    });
  }

  handleAttachmentFileChanged(event) {
    var currentAttachmentFile = this.state.currentAttachmentFile;

    currentAttachmentFile.attachment_file  = event.target.value;

    this.setState({
      currentAttachmentFile: currentAttachmentFile
    });
  }

  renderErrors() {
    var errors  = this.state.errors;

    if(errors.length > 0) {
      var errorItems  = [];

      for(var i = 0; i < errors.length; i++) {
        errorItems.push(
          <li key={"e-" + i}>
            {errors[i]}
          </li>
        );
      }

      return  (
        <div className="callout callout-danger">
          <ul>
            {errorItems}
          </ul>
        </div>
      );
    }
  }

  renderRecords() {
    var attachmentFiles = this.props.data.attachment_files;
    if(attachmentFiles){  
      if(attachmentFiles.length > 0) {
        var records = [];

        for(var i = 0; i < attachmentFiles.length; i++) {
          var name          = attachmentFiles[i].name;
          
          records.push(
            <tr key={"ld-record-" + i}>
              <td>
                {name}
              </td>
              <td>
                <center>
                  <button
                    className="btn btn-sm btn-danger"
                    onClick={this.handleDeleteClicked.bind(this, i)}
                  >
                    <span className="fa fa-minus"/>
                    Del
                  </button>
                </center>
              </td>
            </tr>
          );
        }

        return  (
          <table className="table table-sm">
            <thead>
              <tr>
                <th>Name</th>
                <th>
                  <center>
                    Actions
                  </center>
                </th>
              </tr>
            </thead>
            <tbody>
              {records}
            </tbody>
          </table>
        );
      }
    } else {
      return  (
        <p>
          No attachment files
        </p>
      );
    }
  }

  render() {
    var currentAttachmentFile = this.state.currentAttachmentFile;

    return (
      <div>
        <Modal
          isOpen={this.state.modalIsOpen}
          style={customStyles}
        >
          <h5>
            Attachment File Information
          </h5>
          <div className="row">
            <div className="col">
              <div className="form-group">
                <label>FILE NAME</label>
                <select
                  className="form-control"
                  value={currentAttachmentFile.name}
                  onChange={this.handleNameChanged.bind(this)}
                >
                  <option value="">-- SELECT --</option>
                  <option value="BLIPFORM">BLIPFORM</option>
                  <option value="ID">ID</option>
                  <option value="BC">BC</option>
                  <option value="MC">MC</option>
                  <option value="COHABITATION">COHABITATION</option>
                  <option value="OTHERFILE">OTHERFILE</option>
                </select>
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>FILE</label>
                <input
                  type="file"
                  className="form-control"
                  value={currentAttachmentFile.attachment_file}
                  onChange={this.handleAttachmentFileChanged.bind(this)}
                />
              </div>
            </div>      
          </div>
          {this.renderErrors()}
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

        {this.renderRecords()}

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
