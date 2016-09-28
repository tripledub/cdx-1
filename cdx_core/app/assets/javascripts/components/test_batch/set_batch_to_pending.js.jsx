class SetBatchToPending extends React.Component{
  render() {
    return(
      <div className="row">
        { !this.props.encounter.paymentDone ?
          <AddPaymentAction submitPaymentUrl={ this.props.submitPaymentUrl } authenticityToken={ this.props.authenticityToken } />
          : null }
          &nbsp;  &nbsp; &nbsp;
        { this.props.encounter.status == 'new' ?
          <AddSamplesAction batchId={ this.props.encounter.batchId } submitSamplesUrl={ this.props.submitSamplesUrl } authenticityToken={ this.props.authenticityToken } />
          : null }
      </div>
    )
  }
}

SetBatchToPending.propTypes = {
  encounter: React.PropTypes.object,
  submitSamplesUrl: React.PropTypes.string.isRequired,
  submitPaymentUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
};
