import React from 'react';
import Modal from 'react-modal';

import OptionEditor from './OptionEditor';

const customStyles = {
  content : {
    top                   : '50%',
    left                  : '50%',
    right                 : 'auto',
    bottom                : 'auto',
    marginRight           : '-50%',
    transform             : 'translate(-50%, -50%)',
    width                 : '50%'
  }
};

Modal.setAppElement("#survey-content")

export default class ModalQuestionEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      question: this.props.question
    }
  }

  addOption() {
    var question  = this.state.question;
    
    var option  = {
      content: "",
      score: 0
    }

    question.options.push(option);

    // TODO: Sort options

    this.setState({
      question: question
    });
  }

  removeOption(index) {
    var data      = this.props.data;
    var question  = this.state.question

    question.options.splice(index, 1);

    this.setState({
      question: question
    });
  }

  updateOption(option, index) {
    var data      = this.props.data;
    var question  = this.state.question;

    question.options[index] = option;

    this.setState({
      question: question
    });
  }

  handleSaveClicked() {
    var data      = this.props.data;
    var question  = this.state.question
    var questions = data.data.questions;

    var updated = false;
    for(var i = 0; i < questions.length; i++) {
      if(questions[i].id == question.id) {
        questions[i]  = question;
        updated       = true;
      }
    }

    if(!updated) {
      questions.push(question);
    }

    data.data.questions = questions;

    // TODO: Sort questions

    this.props.updateData(data);

    // Reset new question
    this.setState({
      question: {
        id: "",
        content: "",
        priority: 0,
        isMultiple: false,
        type: "options",
        options: []
      },
    });
  }

  handleCancelClicked() {
    this.props.closeSurveyQuestionEditorModal();
  }

  handleContentChanged(event) {
    var question      = this.state.question;
    question.content  = event.target.value;

    this.setState({
      question: question
    });
  }

  handlePriorityChanged(event) {
    var question      = this.state.question;
    question.priority = event.target.value;

    this.setState({
      question: question
    });
  }

  renderOptions() {
    var question  = this.state.question;

    if(question.type == "options") {
      var options         = question.options;
      var optionsDisplay  = [];

      if(options.length > 0) {
        for(var i = 0; i < options.length; i++) {
          optionsDisplay.push(
            <div
              key={"question-" + question.id + "-option-" + i}
            >
              <OptionEditor
                option={options[i]}
                index={i}
                removeOption={this.removeOption.bind(this)}
                updateOption={this.updateOption.bind(this)}
              />
            </div>
          );
        }

        return  (
          <div>
            {optionsDisplay}
          </div>
        );
      } else {
        return  (
          <p>
            No options yet.
          </p>
        );
      }
    } else {
      return  (
        <p>
          Invalid question type: {question.type}
        </p>
      );
    }
  }

  render() {
    var question  = this.state.question;

    return  (
      <Modal
        isOpen={this.props.modalSurveyQuestionEditorIsOpen}
        style={customStyles}
      >
        <div className="container">
          <div className="row">
            <div className="col-md-10">
              <div className="form-group">
                <label>
                  Question Content:
                </label>
                <input
                  type="text"
                  className="form-control"
                  value={question.content}
                  onChange={this.handleContentChanged.bind(this)}
                />
              </div>
            </div>
            <div className="col-md-2">
              <div className="form-group">
                <label>
                  Priority
                </label>
                <input
                  type="number"
                  className="form-control"
                  value={question.priority}
                  onChange={this.handlePriorityChanged.bind(this)}
                />
              </div>
            </div>
          </div>
          <hr/>
          {this.renderOptions()}
          <div className="row">
            <div className="col">
              <div className="text-right">
                <button
                  className="btn btn-info btn-sm"
                  onClick={this.addOption.bind(this)}
                >
                  <span className="fa fa-plus"/>
                  Add Option
                </button>
              </div>
            </div>
          </div>
          <hr/>
          <center>
            <div className="btn-group">
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
            </div>
          </center>
        </div>
      </Modal>
    );
  }
}
