import React from "react";
import $ from "jquery";

import SkCubeLoading from '../SkCubeLoading';

export default class InsuranceStatusComponent extends React.Component {
	constructor(props){
		super(props);

		this.state = {
			message: "hello",
			isLoading: true,
			memberAccountId: props.memberAccountId,
			data: false
		};
	}
	componentDidMount(){
		var memberAccountId = this.state.memberAccountId;
		var context = this;
		$.ajax({
			url: "/api/v1/insurance_accounts/fetch_insurance_status",
			method: "GET",
			data: {
				member_account_id: memberAccountId
			},
			success: function(response){
				console.log(response);
				context.setState({
					isLoading: false,
					data: response 
				})
			},
			error: function(response){
				alert("Error fetch data")
			}
		})
	}

	handleInputChange(event){
		var newMessage = event.target.value;
		this.setState({
			message: newMessage
		});
	}
	handleSaveClicked(){
		var message = this.state.message;
		alert(message);
	}

	render() {
		var context = this;
		var message = this.state.message
		if(context.state.isLoading){
			return( <SkCubeLoading/>)
		}
		else{
			var currentDate = context.state.data.current_date;
			return (
			<div>
				<input type="text" onChange={this.handleInputChange.bind(this)}/>
				<button className = "btn btn-primary" onClick={this.handleSaveClicked.bind(this)}>Submit</button>
				<h1>{message}</h1>
				<h2>{message}</h2>
				<hr></hr>
				<table>
				<tbody>
				<th>Current Date</th>
				<td>{currentDate}</td>
				</tbody>
				</table>
			</div>
		);
		}
		
	}
}