var TestResultRow = React.createClass({
  render: function() {
    return (
      <tr data-href={ this.props.testResult.viewLink }>
        <td>{ this.props.testResult.name }</td>
        <td>{ this.props.testResult.assays }</td>
        <td>{ this.props.testResult.siteName }</td>
        <td>{ this.props.testResult.deviceName }</td>
        <td>{ this.props.testResult.sampleId }</td>
        <td>{ this.props.testResult.status }</td>
        <td>{ this.props.testResult.collectedAt }</td>
        <td>{ this.props.testResult.resultAt }</td>
      </tr>
    );
  }
});

var TestResultsList = React.createClass({
  getDefaultProps: function() {
    return {
      allowSorting: true,
      orderBy: "patient_results.sample_collected_at",
    }
  },

  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={ title } field={ field } orderBy={ this.props.orderBy } />
    }.bind(this);

    return (
      <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="test-results-table">
        <thead>
          <tr>
            { sortableHeader(I18n.t("components.test_results.col_test"), "patient_results.result_name ") }
            <th>{ I18n.t("components.test_results.col_result") }</th>
            { sortableHeader(I18n.t("components.test_results.col_site"), "sites.name") }
            { sortableHeader(I18n.t("components.test_results.col_device_name"), "devices.name") }
            { sortableHeader(I18n.t("components.test_results.col_sample_id"), "sample_identifiers.entity_id") }
            { sortableHeader(I18n.t("components.test_results.col_status"), "patient_results.result_status") }
            { sortableHeader(I18n.t("components.test_results.col_start_time"), "patient_results.sample_collected_at") }
            { sortableHeader(I18n.t("components.test_results.col_end_time"), "patient_results.result_at") }
          </tr>
        </thead>
        <tbody>
          { this.props.testResults.map(function(testResult) {
            return <TestResultRow key={ testResult.id } testResult={ testResult } />;
          }.bind(this))}
        </tbody>
      </table>
    );
  }
});
