class SetBatchToPending extends React.Component{
  render() {
    return(
      <div className="col-6">
        { !this.props.testBatch.paymentDone ?
          <AddPaymentAction submitPaymentUrl={ this.props.submitPaymentUrl } authenticityToken={ this.props.authenticityToken } />
          : null }
        { this.props.testBatch.status == 'new' ?
          <AddSamplesAction batchId={ this.props.batchId } testBatch={ this.props.testBatch } submitSamplesUrl={ this.props.submitSamplesUrl } authenticityToken={ this.props.authenticityToken } />
          : null }
      </div>
    )
  }
}

SetBatchToPending.propTypes = {
  testBatch: React.PropTypes.object,
  batchId: React.PropTypes.string,
  submitSamplesUrl: React.PropTypes.string,
  authenticityToken: React.PropTypes.string,
};
