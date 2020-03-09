import React from "react";

export default class Portfolio extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      data: props.data
    }
    console.log(this.state);
  }

  componentDidMount() {
    var context = this.state;

    if(context.data) {
    }
  }

  componentDidUpdate() {
    var context = this.state;
  }

  render() {
    var context = this.state;

    console.log(context.data);

    if(context.data) {
      return  <div>
                <h5>Portfolio</h5>
              </div>
    } else {
      return  <div>
                No Data
              </div>
    }
  }
}
