class TestBatchList extends React.Component{
  render() {
    return(
      <div className="row">
        <TestBatchTable patientResults={ this.props.testBatch.patientResults } paymentDone={ this.props.testBatch.paymentDone } rejectReasons={ this.props.rejectReasons } updateResultUrl={ this.props.updateResultUrl } />
        <TestBatchActions testOrderStatus={ this.props.testOrderStatus } batchId={ this.props.testBatch.batchId } testBatch= { this.props.testBatch } submitPaymentUrl={ this.props.submitPaymentUrl } submitSamplesUrl={ this.props.submitSamplesUrl }  authenticityToken={ this.props.authenticityToken } />
      </div>
    );
  }
}

TestBatchList.propTypes = {
  testBatch: React.PropTypes.object.isRequired,
  submitSamplesUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
  testOrderStatus: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  submitPaymentUrl: React.PropTypes.string.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
};
