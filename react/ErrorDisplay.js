import React from "react";

export default class ErrorDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      errors: {
        messages: [],
        fullMessages: [] 
      }
    }
  }

  renderFullMessages() {
    var context       = this;
    var fullMessages  = context.state.fullMessages;

    listItemMessages  = [];

    for(var i = 0; i < fullMessages.length; i++) {
      listItemMessages.push(
        <li key={"error-message-" + i}>
          {fullMessages[i]}
        </li>
      );
    }
  };

  render() {
    return  (
      <div className="error-display">
        <div className="callout callout-danger">
          <ul>
          </ul>
        </div>
      </div>
    );
  }
}
