var MicroscopyResultRow = React.createClass({
  render: function() {
    return (
      <tr data-href={this.props.testResult.viewLink}>
        <td>{this.props.testResult.sampleCollectedOn}</td>
        <td>{this.props.testResult.serialNumber}</td>
        <td>{this.props.testResult.examinedBy}</td>
        <td>{this.props.testResult.specimenType}</td>
        <td>{this.props.testResult.appearance}</td>
        <td>{this.props.testResult.testResult}</td>
        <td>{this.props.testResult.resultOn}</td>
      </tr>
    );
  }
});

var MicroscopyResultsIndex = React.createClass({
  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy='patient_results.updated_at' />
    }.bind(this);

    return (
      <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="microscopy-test-results-table">
        <thead>
          <tr>
            {sortableHeader('Sample collected on', 'patient_results.sample_collected_on')}
            {sortableHeader('Serial number',       'patient_results.serial_number')}
            {sortableHeader('Examined by',         'patient_results.examined_by')}
            {sortableHeader('Specimen type',       'patient_results.specimen_type')}
            {sortableHeader('Appearance',          'patient_results.appearance')}
            {sortableHeader('Test result',         'patient_results.test_result')}
            {sortableHeader('Result on',           'patient_results.result_on')}
          </tr>
        </thead>
        <tbody>
          {
            this.props.testResults.map(function(testResult) {
             return <MicroscopyResultRow key={testResult.id} testResult={testResult} />;
            })
          }
        </tbody>
      </table>
    );
  }
});
