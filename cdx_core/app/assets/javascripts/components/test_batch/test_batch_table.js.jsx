class TestBatchTable extends React.Component{
  render() {
    return(
      <table className="table testBatchTable" cellPadding="0" cellSpacing="0">
        <thead>
          <tr>
            <th>{ I18n.t('components.test_batch_table.type') }</th>
            <th>{ I18n.t('components.test_batch_table.sample_id') }</th>
            <th>{ I18n.t('components.test_batch_table.examined_by') }</th>
            <th>{ I18n.t('components.test_batch_table.options') }</th>
          </tr>
        </thead>
        <tbody>
          { this.props.patientResults.map(function(patientResult) {
             return <TestBatchRow key={ patientResult.id } paymentDone={ this.props.paymentDone } rejectReasons={ this.props.rejectReasons } patientResult={ patientResult } updateResultUrl={ this.props.updateResultUrl } />;
          }.bind(this)) }
        </tbody>
      </table>
    );
  }
}

TestBatchTable.propTypes = {
  patientResults: React.PropTypes.array,
  rejectReasons: React.PropTypes.object.isRequired,
  paymentDone: React.PropTypes.bool.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
};
