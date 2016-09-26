class TestBatchActions extends React.Component{
  render() {
    return(
      <div className="row">
        { this.props.testOrderStatus == 'new' ?
          <SetBatchToPending  testOrderStatus={ this.props.testOrderStatus } batchId={ this.props.batchId } testBatch={ this.props.testBatch } submitSamplesUrl={ this.props.submitSamplesUrl }  submitPaymentUrl={ this.props.submitPaymentUrl } authenticityToken={ this.props.authenticityToken } />
          : null }
      </div>
    );
  }
}

TestBatchActions.propTypes = {
  testBatch: React.PropTypes.object,
  batchId: React.PropTypes.string,
  submitSamplesUrl: React.PropTypes.string,
  submitPaymentUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string,
  testOrderStatus: React.PropTypes.string,
};
