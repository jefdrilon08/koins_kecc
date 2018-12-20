import React from 'react';
import $ from 'jquery';

import SkCubeLoading from '../SkCubeLoading';
import {numberWithCommas} from '../utils/helpers';

export default class ShowUI extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false
    };
  }

  componentDidMount() {
    var id                = this.props.id;
    var authenticityToken = this.props.authenticityToken;
    var context           = this;

    $.ajax({
      url: "/api/v1/monthly_closing_collections/fetch",
      method: 'GET',
      data: {
        id: id
      },
      success: function(response) {
        context.setState({
          isLoading: false,
          data: response
        });
      },
      error: function(response) {
        alert("Error in fetching data");
      }
    });
  }

  render() {
    var context = this;

    if(context.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else {
      console.log(context.state.data);
      return  (
        <div>
        </div>
      );
    }
  }
}
