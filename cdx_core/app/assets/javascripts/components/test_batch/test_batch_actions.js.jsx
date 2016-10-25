class TestBatchActions extends React.Component{
  render() {
    return(
      <div className="row mainactions">
        { this.props.testOrderStatus === 'new' && this.props.encounter.userCanFinance ?
          <AddPaymentAction rejectReasons={ this.props.rejectReasons } commentValue={ this.props.encounter.comment } encounterRoutes={ this.props.encounterRoutes } authenticityToken={ this.props.authenticityToken } /> : null }
        { this.props.testOrderStatus === 'financed' ?
          <AddSamplesAction batchId={ this.props.encounter.batch_id } manualSampleId={ this.props.manualSampleId } patientResults={ this.props.patientResults } encounterRoutes={ this.props.encounterRoutes } authenticityToken={ this.props.authenticityToken } /> : null }
      </div>
    );
  }
}

TestBatchActions.propTypes = {
  encounterRoutes: React.PropTypes.object.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  patientResults: React.PropTypes.array.isRequired,
  encounter: React.PropTypes.object.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
  testOrderStatus: React.PropTypes.string.isRequired,
  manualSampleId: React.PropTypes.bool.isRequired,
};
