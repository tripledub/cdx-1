class TestBatchTable extends React.Component{
  render() {
    return(
      <table className="table testResultsTable" cellPadding="0" cellSpacing="0">
        <thead>
          <tr>
            <th>{ I18n.t('components.test_batch_table.type') }</th>
            <th>{ I18n.t('components.test_batch_table.sample_id') }</th>
            <th>{ I18n.t('components.test_batch_table.examined_by') }</th>
            <th>{ I18n.t('components.test_batch_table.status') }</th>
            <th>{ I18n.t('components.test_batch_table.options') }</th>
          </tr>
        </thead>
        <tbody>
          { this.props.patientResults.map(function(patientResult) {
             return <TestBatchRow key={ patientResult.id } rejectReasons={ this.props.rejectReasons } patientResult={ patientResult } encounterRoutes={ this.props.encounterRoutes } />;
          }.bind(this)) }
        </tbody>
      </table>
    );
  }
}

TestBatchTable.propTypes = {
  patientResults: React.PropTypes.array.isRequired,
  encounter: React.PropTypes.object.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  encounterRoutes: React.PropTypes.object.isRequired,
};
