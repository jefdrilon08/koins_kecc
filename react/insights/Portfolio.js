import React from "react";
import c3 from "c3";

export default class Portfolio extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      data: props.data
    }
    console.log(this.state);
  }

  renderChart() {
    var context = this.state;

    console.log("Rendering chart...");

    const chart = c3.generate({
      bindto: "#portfolio-chart",
      data: {
        columns: context.data,
        type: 'line'
      }
    });
  }

  componentDidMount() {
    var context = this.state;

    if(context.data) {
      this.renderChart();
    }
  }

  componentDidUpdate() {
    var context = this.state;

    if(context.data) {
      this.renderChart();
    }
  }

  render() {
    var context = this.state;

    console.log(context.data);

    if(context.data) {
      return  <div>
                <h5>Portfolio</h5>
                <div id="#portfolio-chart">
                </div>
              </div>
    } else {
      return  <div>
                No Data
              </div>
    }
  }
}
