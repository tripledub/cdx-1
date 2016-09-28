class TestBatchList extends React.Component{
  render() {
    return(
      <div className="row">
        <TestBatchTable encounter={ this.props.encounter } patientResults={ this.props.patientResults } rejectReasons={ this.props.rejectReasons } updateResultUrl={ this.props.updateResultUrl } />
        <TestBatchActions encounter= { this.props.encounter } patientResults={ this.props.patientResults } submitPaymentUrl={ this.props.submitPaymentUrl } submitSamplesUrl={ this.props.submitSamplesUrl }  authenticityToken={ this.props.authenticityToken } />
      </div>
    );
  }
}

TestBatchList.propTypes = {
  encounter: React.PropTypes.object.isRequired,
  patientResults: React.PropTypes.array.isRequired,
  submitSamplesUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  submitPaymentUrl: React.PropTypes.string.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
};
