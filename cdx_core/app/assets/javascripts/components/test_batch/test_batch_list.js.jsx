class TestBatchList extends React.Component{
  render() {
    return(
      <div className="row">
        <TestBatchHeader batchId={ this.props.testBatch.batchId } status={ this.props.testBatch.status } />
        <TestBatchTable patientResults={ this.props.testBatch.patientResults } />
        <TestBatchActions batchId={ this.props.testBatch.batchId } testBatch= { this.props.testBatch } submitSamplesUrl={ this.props.submitSamplesUrl }  authenticityToken={ this.props.authenticityToken } />
      </div>
    );
  }
}

TestBatchList.propTypes = {
  testBatch: React.PropTypes.object,
  submitSamplesUrl: React.PropTypes.string,
  authenticityToken: React.PropTypes.string,
};
