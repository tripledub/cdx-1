var CultureResultRow = React.createClass({
  render: function() {
    return (
      <tr data-href={this.props.testResult.viewLink}>
        <td>{this.props.testResult.sampleCollectedOn}</td>
        <td>{this.props.testResult.serialNumber}</td>
        <td>{this.props.testResult.examinedBy}</td>
        <td>{this.props.testResult.mediaUsed}</td>
        <td>{this.props.testResult.testResult}</td>
        <td>{this.props.testResult.resultOn}</td>
      </tr>
    );
  }
});

var CultureResultsIndex = React.createClass({
  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy='patient_results.sample_collected_on' />
    }.bind(this);

    return (
      <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="culture-test-results-table">
        <thead>
          <tr>
            {sortableHeader('Sample collected on', 'patient_results.sample_collected_on')}
            {sortableHeader('Serial number',       'patient_results.serial_number')}
            {sortableHeader('Examined by',         'patient_results.examined_by')}
            {sortableHeader('Media used',          'patient_results.media_used')}
            {sortableHeader('Test result',         'patient_results.test_result')}
            {sortableHeader('Result on',           'patient_results.result_on')}
          </tr>
        </thead>
        <tbody>
          {
            this.props.testResults.map(function(testResult) {
             return <CultureResultRow key={testResult.id} testResult={testResult} />;
            })
          }
        </tbody>
      </table>
    );
  }
});
