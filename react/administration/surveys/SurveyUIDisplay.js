import React from 'react';
import $ from 'jquery';
import moment from 'moment';

import SkCubeLoading from '../../SkCubeLoading';
import {numberWithCommas} from '../../utils/helpers';

import ModalSurveyName from './ModalSurveyName';
import ModalQuestionEditor from './ModalQuestionEditor';

export default class SurveyUIDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      isSaving: false,
      modalSurveyNameIsOpen: false,
      modalSurveyQuestionEditorIsOpen: false,
      currentQuestion: {
        id: "",
        content: "",
        priority: 0,
        isMultiple: false,
        type: "options",
        options: []
      },
      data: false
    };
  }

  componentDidMount() {
    this.fetchSurveyData();
  }

  closeSurveyNameModal() {
    this.setState({
      modalSurveyNameIsOpen: false
    });
  }

  closeSurveyQuestionEditorModal() {
    this.setState({
      modalSurveyQuestionEditorIsOpen: false
    });
  }

  openSurveyNameModal() {
    this.setState({
      modalSurveyNameIsOpen: true
    });
  }

  openSurveyQuestionEditorModal() {
    this.setState({
      modalSurveyQuestionEditorIsOpen: true
    });
  }

  fetchSurveyData() {
    var context = this;

    $.ajax({
      url: "/api/v1/administration/surveys/fetch",
      method: 'GET',
      data: {
        id: this.props.id
      },
      success: function(response) {
        context.setState({
          isLoading: false,
          data: response
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching survey");
      }
    });
  }

  updateData(data) {
    this.setState({
      data: data,
      modalSurveyNameIsOpen: false,
      modalSurveyQuestionEditorIsOpen: false,
      currentQuestion: {
        id: "",
        content: "",
        priority: 0,
        isMultiple: false,
        type: "options",
        options: []
      }
    });
  }

  handleQuestionEdit(index) {
    var data              = this.state.data;
    var questions         = data.data.questions;

    this.setState({
      currentQuestion: questions[index],
      modalSurveyQuestionEditorIsOpen: true
    });
  }

  handleNewSurveyQuestionClicked() {
    this.setState({
      currentQuestion: {
        id: "",
        content: "",
        priority: 0,
        isMultiple: false,
        type: "options",
        options: []
      }
    });

    this.openSurveyQuestionEditorModal();
  }

  renderQuestions() {
    var data              = this.state.data;
    var questions         = data.data.questions;
    var questionsDisplay  = [];

    if(questions.length > 0) {
      for(var i = 0; i < questions.length; i++) {
        if(questions[i].type == "options") {
          var optionsDisplay  = [];
          for(var j = 0; j < questions[i].options.length; j++) {
            optionsDisplay.push(
              <li key={"question-" + questions[i].id + "-" + j}>
                {questions[i].options[j].content} (Score: {questions[i].options[j].score})
              </li>
            );
          }

          questionsDisplay.push(
            <div key={"question-" + i}>
              <h5>
                {questions[i].content}
              </h5>
              <ul>
                {optionsDisplay}
              </ul>
              <a href="#" onClick={this.handleQuestionEdit.bind(this, i)}>
                <span className="fa fa-pencil-alt"/>
                Edit Question
              </a>
            </div>
          );
        } else {
          questionsDisplay.push(
            <div key={"question-" + i}>
              Invalid Question Type {questions[i].type}
            </div>
          );
        }
      }

      return  (
        <div>
          {questionsDisplay}
        </div>
      );
    } else {
      return  (
        <p>
          No questions found.
        </p>
      );
    }
  }

  render() {
    var data            = this.state.data;
    var currentQuestion = this.state.currentQuestion;

    console.log(currentQuestion);

    if(this.state.isLoading) {
      return (
        <div>
          <SkCubeLoading/>
        </div>
      );
    } else {
      return (
        <div>
          <ModalSurveyName
            modalSurveyNameIsOpen={this.state.modalSurveyNameIsOpen}
            updateData={this.updateData.bind(this)}
            closeSurveyNameModal={this.closeSurveyNameModal.bind(this)}
            data={data}
          />

          <ModalQuestionEditor
            modalSurveyQuestionEditorIsOpen={this.state.modalSurveyQuestionEditorIsOpen}
            updateData={this.updateData.bind(this)}
            closeSurveyQuestionEditorModal={this.closeSurveyQuestionEditorModal.bind(this)}
            data={data}
            question={currentQuestion}
          />

          <div className="row">
            <div className="col">
              <h3>
                {data.name} &nbsp;
                <small>
                  <a href="#" onClick={this.openSurveyNameModal.bind(this)}>
                    <span className="fa fa-pencil-alt"/>
                    Edit Name
                  </a>
                </small>
              </h3>
              <hr/>
              {this.renderQuestions()}
              <hr/>
              <div className="row">
                <div className="col">
                  <div>
                    <button
                      className="btn btn-info"
                      onClick={this.handleNewSurveyQuestionClicked.bind(this)}
                    >
                      <span className="fa fa-plus"/>
                      Add Question
                    </button>
                  </div>
                </div>
                <div className="col">
                  <div className="text-right">
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      );
    }
  }
}
