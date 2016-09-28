class TestBatchActions extends React.Component{
  render() {
    return(
      <div className="row">
        { this.props.testOrderStatus == 'new' ?
          <SetBatchToPending  testOrderStatus={ this.props.encounter.status } batchId={ this.props.encounter.batchId } submitSamplesUrl={ this.props.submitSamplesUrl }  submitPaymentUrl={ this.props.submitPaymentUrl } authenticityToken={ this.props.authenticityToken } />
          : null }
      </div>
    );
  }
}

TestBatchActions.propTypes = {
  encounter: React.PropTypes.object,
  submitSamplesUrl: React.PropTypes.string,
  submitPaymentUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string,
};
