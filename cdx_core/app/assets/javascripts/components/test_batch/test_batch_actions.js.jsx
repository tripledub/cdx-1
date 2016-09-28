class TestBatchActions extends React.Component{
  render() {
    return(
      <div className="row">
        { this.props.testOrderStatus == 'new' ?
          <SetBatchToPending  encounter={ this.props.encounter } patientResults={ this.props.patientResults } submitSamplesUrl={ this.props.submitSamplesUrl }  submitPaymentUrl={ this.props.submitPaymentUrl } authenticityToken={ this.props.authenticityToken } />
          : null }
      </div>
    );
  }
}

TestBatchActions.propTypes = {
  patientResults: React.PropTypes.array.isRequired,
  encounter: React.PropTypes.object,
  submitSamplesUrl: React.PropTypes.string,
  submitPaymentUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string,
};
