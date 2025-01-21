import React from "react";

export default class ApplicationTransferOption extends React.Component{
	constructor(props){
		super(props);

		this.state = {
			paymentType: this.props.data.paymentType || "",
      		subType: this.props.data.subType|| "",
		}
	}

	static getDerivedStateFromProps(nextProps, prevState) {
		if (
		  nextProps.data.paymentType !== prevState.paymentType ||
		  nextProps.data.subType !== prevState.subType
		) {
		  return {
			paymentType: nextProps.data.paymentType || "",
			subType: nextProps.data.subType || "",
		  };
		}
		return null;
	  }
	
	handleBankTransferOptionChanged(event) {
		var data = this.props.data;

		data.bank_id = event.target.value;

		this.props.updateData(data);
	}

	 // Handle Payment Type change
	 handlePaymentTypeChanged(event) {
		const selectedPaymentType = event.target.value;
		console.log("Payment Type selected:", selectedPaymentType);
		
		this.setState({ paymentType: selectedPaymentType });
		this.props.updateData({
			...this.props.data,
			paymentType: selectedPaymentType, 
		});
	}
	
	  // Handle Sub Type change
	  handleSubTypeChanged(event) {
		const selectedSubType = event.target.value;
		console.log("Sub Type selected:", selectedSubType);
		
		this.setState({ subType: selectedSubType });
		this.props.updateData({
			...this.props.data,
			subType: selectedSubType,
		});
	  }

	render() {
		var bankTransferOptions = [];
		var { paymentType, subType } = this.state;


		bankTransferOptions.push(
			<option key={"transfer-select"}>
				-- SELECT --
			</option>
		);

		var TransferOptions = [];
		TransferOptions.push(
			<option key={"bank-select"}>
				-- SELECT --
			</option>
		);

		var PaymentType = [
			<option key={"payment-select"}>-- SELECT --</option>,
			<option key={"USSC"} value="USSC">
			  USSC
			</option>,
		];
	  
		var SubType = [
			<option key={"sub-select"}>-- SELECT --</option>,
			<option key={"E-WALLET"} value="E-WALLET">
			  E-Wallet
			</option>,
		];

		for(var i = 0; i < this.props.optionTransfer.length; i++) {
			if(this.props.optionTransfer[i].id == this.props.currentBankTransferId) {
				for(var j = 0; j < this.props.optionTransfer[i].bank_transfers.length; j++) {
					TransferOptions.push(
						<option key={"bank-option-" + this.props.optionTransfer[i].bank_transfers[j].id} value={this.props.optionTransfer[i].bank_transfers[j].id}>
						{this.props.optionTransfer[i].bank_transfers[j].name}
					</option>
					);
				}
			}
			bankTransferOptions.push(
				<option
					key={"transfer-option-" + i}
					value={this.props.optionTransfer[i].id}
				>
					{this.props.optionTransfer[i].name}
				</option>
			);
		}
		return (
			<div>
				<div className="row">
					<div className="col">
						<div className="form-group">
							<label>
								Transfer Option
							</label>
							<select
								onChange={this.props.handleTransferOptionChanged.bind(this)}
								className="form-control"
								value={this.props.currentBankTransferId}
								disabled={this.props.disabled}
							>
								{bankTransferOptions}
							</select>
						</div>
					</div>
					<div className="col">
						<div className="form-group">
						<label>
							Bank & Ewallet
						</label>
						<select
							className="form-control"
							disabled={this.props.disabled}
							value={this.props.data.bank_id}
							onChange={this.handleBankTransferOptionChanged.bind(this)}
						>
							{TransferOptions}
						</select>
						</div>
					</div>
				</div>	
				<div className="row">
					<div className="col">
						<div className="form-group">
							<label>Payment Type</label>
							<select
								className="form-control"
								value={paymentType}
								onChange={this.handlePaymentTypeChanged.bind(this)} 
								disabled={this.props.disabled}
							>
								{PaymentType}
							</select>
						</div>
					</div>
					<div className="col">
						<div className="form-group">
							<label>Sub Type</label>
							<select
								className="form-control"
								value={subType}
								onChange={this.handleSubTypeChanged.bind(this)} 
								disabled={this.props.disabled}
							>
								{SubType}
							</select>
						</div>
					</div>
				</div>
			</div>
		);
	}
}