var DstLpaResultRow = React.createClass({
  render: function() {
    return (
      <tr data-href={this.props.testResult.viewLink}>
        <td>{this.props.testResult.sampleCollectedOn}</td>
        <td>{this.props.testResult.serialNumber}</td>
        <td>{this.props.testResult.examinedBy}</td>
        <td>{this.props.testResult.mediaUsed}</td>
        <td>{this.props.testResult.resultH}</td>
        <td>{this.props.testResult.resultR}</td>
        <td>{this.props.testResult.resultE}</td>
        <td>{this.props.testResult.resultS}</td>
        <td>{this.props.testResult.resultAmk}</td>
        <td>{this.props.testResult.resultKm}</td>
        <td>{this.props.testResult.resultCm}</td>
        <td>{this.props.testResult.resultFq}</td>
        <td>{this.props.testResult.resultOn}</td>
      </tr>
    );
  }
});

var DstLpaResultsIndex = React.createClass({
  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy='patient_results.sample_collected_on' />
    }.bind(this);

    return (
      <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="dstlpa-test-results-table">
        <thead>
          <tr>
            {sortableHeader('Sample collected on', 'patient_results.sample_collected_on')}
            {sortableHeader('Serial number',       'patient_results.serial_number')}
            {sortableHeader('Examined by',         'patient_results.examined_by')}
            {sortableHeader('Media used',          'patient_results.media_used')}
            {sortableHeader('Results H',           'patient_results.results_h')}
            {sortableHeader('Results R',           'patient_results.results_r')}
            {sortableHeader('Results E',           'patient_results.results_e')}
            {sortableHeader('Results S',           'patient_results.results_s')}
            {sortableHeader('Results Amk',         'patient_results.results_amk')}
            {sortableHeader('Results Km',          'patient_results.results_km')}
            {sortableHeader('Results Cm',          'patient_results.results_cm')}
            {sortableHeader('Results Fq',          'patient_results.results_fq')}
            {sortableHeader('Result on',           'patient_results.result_on')}
          </tr>
        </thead>
        <tbody>
          {
            this.props.testResults.map(function(testResult) {
             return <DstLpaResultRow key={testResult.id} testResult={testResult} />;
            })
          }
        </tbody>
      </table>
    );
  }
});
