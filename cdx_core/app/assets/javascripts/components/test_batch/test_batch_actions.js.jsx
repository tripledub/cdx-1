class TestBatchActions extends React.Component{
  render() {
    return(
      <div className="row">
        <AddSamplesAction batchId={ this.props.batchId } testBatch={ this.props.testBatch } submitSamplesUrl={ this.props.submitSamplesUrl }  authenticityToken={ this.props.authenticityToken }/>
      </div>
    );
  }
}

TestBatchActions.propTypes = {
  testBatch: React.PropTypes.object,
  batchId: React.PropTypes.string,
  submitSamplesUrl: React.PropTypes.string,
  authenticityToken: React.PropTypes.string,
};
