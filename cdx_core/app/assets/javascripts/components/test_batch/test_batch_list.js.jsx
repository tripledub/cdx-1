class TestBatchList extends React.Component{
  render() {
    return(
      <div className="row">
        <TestBatchHeader batchId={ this.props.testBatch.batchId } status={ this.props.testBatch.status } paymentDone= { this.props.testBatch.paymentDone }/>
        <TestBatchTable patientResults={ this.props.testBatch.patientResults } rejectReasons={ this.props.rejectReasons } updateResultUrl={ this.props.updateResultUrl } />
        <TestBatchActions encounterStatus={ this.props.encounterStatus } batchId={ this.props.testBatch.batchId } testBatch= { this.props.testBatch } submitPaymentUrl={ this.props.submitPaymentUrl } submitSamplesUrl={ this.props.submitSamplesUrl }  authenticityToken={ this.props.authenticityToken } />
      </div>
    );
  }
}

TestBatchList.propTypes = {
  testBatch: React.PropTypes.object.isRequired,
  submitSamplesUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
  encounterStatus: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  submitPaymentUrl: React.PropTypes.string.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
};
