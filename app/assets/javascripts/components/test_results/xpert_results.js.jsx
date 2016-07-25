var XpertResultRow = React.createClass({
  render: function() {
    return (
      <tr data-href={this.props.testResult.viewLink}>
        <td>{this.props.testResult.sampleCollectedOn}</td>
        <td>{this.props.testResult.examinedBy}</td>
        <td>{this.props.testResult.tuberculosis}</td>
        <td>{this.props.testResult.trace}</td>
        <td>{this.props.testResult.rifampicin}</td>
        <td>{this.props.testResult.resultOn}</td>
      </tr>
    );
  }
});

var XpertResultsIndex = React.createClass({
  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy='patient_results.updated_at' />
    }.bind(this);

    return (
      <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="xpert-test-results-table">
        <thead>
          <tr>
            {sortableHeader('Sample collected on', 'patient_results.sample_collected_on')}
            {sortableHeader('Examined by',         'patient_results.examined_by')}
            {sortableHeader('Tuberculosis',        'patient_results.tuberculosis')}
            {sortableHeader('Trace',               'patient_results.trace')}
            {sortableHeader('Rifampicin',          'patient_results.rifampicin')}
            {sortableHeader('Result on',           'patient_results.result_on')}
          </tr>
        </thead>
        <tbody>
          {
            this.props.testResults.map(function(testResult) {
             return <XpertResultRow key={testResult.id} testResult={testResult} />;
            })
          }
        </tbody>
      </table>
    );
  }
});
