class TestBatchList extends React.Component{
  render() {
    return(
      <div className="row">
        <TestBatchTable encounter={ this.props.encounter } patientResults={ this.props.patientResults } rejectReasons={ this.props.rejectReasons } encounterRoutes={ this.props.encounterRoutes } />
        <TestBatchActions encounter= { this.props.encounter } manualSampleId={ this.props.manualSampleId } testOrderStatus={ this.props.testOrderStatus } patientResults={ this.props.patientResults } rejectReasons={ this.props.rejectReasons } encounterRoutes={ this.props.encounterRoutes } authenticityToken={ this.props.authenticityToken } />
      </div>
    );
  }
}

TestBatchList.propTypes = {
  encounter: React.PropTypes.object.isRequired,
  patientResults: React.PropTypes.array.isRequired,
  encounterRoutes: React.PropTypes.object.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  testOrderStatus: React.PropTypes.string.isRequired,
  manualSampleId: React.PropTypes.bool.isRequired,
};
