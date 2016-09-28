class TestBatchList extends React.Component{
  render() {
    return(
      <div className="row">
        <TestBatchTable patientResults={ this.props.encounter.patientResults } userCanApprove={ this.props.encounter.userCanApprove } paymentDone={ this.props.encounter.paymentDone } rejectReasons={ this.props.rejectReasons } updateResultUrl={ this.props.updateResultUrl } />
        <TestBatchActions testOrderStatus={ this.props.encounter.status } batchId={ this.props.encounter.batchId } encounter= { this.props.encounter } submitPaymentUrl={ this.props.submitPaymentUrl } submitSamplesUrl={ this.props.submitSamplesUrl }  authenticityToken={ this.props.authenticityToken } />
      </div>
    );
  }
}

TestBatchList.propTypes = {
  encounter: React.PropTypes.object.isRequired,
  submitSamplesUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  submitPaymentUrl: React.PropTypes.string.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
};
