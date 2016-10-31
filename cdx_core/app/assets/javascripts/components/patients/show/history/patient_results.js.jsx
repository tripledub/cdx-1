var PatientResults = React.createClass({
  getInitialState: function() {
    return {
      patientResults: [],
      orderBy: this.props.defaultResultsOrder,
      pagination: {},
      pageNumber: 1,
      loadingMessage: I18n.t("components.patients.show.history.msg_loading_result"),
      availableColumns: [
        { title: I18n.t("components.patients.show.history.col_result_name"),   fieldName: 'patient_results.type' },
        { title: I18n.t("components.patients.show.history.col_result_status"), fieldName: 'patient_results.result_status' },
        { title: I18n.t("components.patients.show.history.col_result_date"),   fieldName: 'patient_results.created_at' }
      ]
    };
  },

  getData: function(field, e) {
    if (e) { e.preventDefault(); }
    this.serverRequest = $.get(this.props.testResultsUrl + this.getParams(field), function (results) {
      if (results['rows'].length > 0) {
        this.setState({ pagination: results['pages'] });
        this.setState({ patientResults: results['rows'] });
        this.setState({ orderBy: results['order_by'] });
        $("table").resizableColumns({store: window.store});
      } else {
        this.setState({ loadingMessage: I18n.t("components.patients.show.history.msg_no_result") });
      };
    }.bind(this));
  },

  pageData: function(pageNumber){
    this.getData(this.state.orderBy, pageNumber)
  },

  getParams: function(field, pageNumber) {
    if (!field) {
      return '';
    };

    if(!pageNumber) {
      pageNumber = this.state.pageNumber;
    }

    this.setState({ pageNumber: pageNumber });
    return '&order_by='+ field + '&page=' + pageNumber;
  },

  componentDidMount: function() {
    this.getData(this.state.orderBy);
  },

  componentWillUnmount: function() {
    this.serverRequest.abort();
  },

  render: function() {
    var rows       = [];
    var rowHeaders = [];
    var that       = this;
    this.state.patientResults.forEach(
      function(patientResult) {
        rows.push(<PatientResult patientResult={ patientResult } key={ patientResult.id } />);
      }
    );

    this.state.availableColumns.forEach(
      function(availableColumn) {
        rowHeaders.push(<OrderedColumnHeader key={ availableColumn.fieldName } title={ availableColumn.title } fieldName={ availableColumn.fieldName } orderEvent={ that.getData } orderBy={ that.state.orderBy } />);
      }
    );

    return (
      <div className="row">
        {
          this.state.patientResults.length < 1 ? <LoadingResults loadingMessage={ this.state.loadingMessage } /> :
          <table className="table patient-results" data-resizable-columns-id="patient-results-table">
            <thead>
              <tr>
                { rowHeaders }
              </tr>
            </thead>
            <tfoot>
              <tr>
                <td>
                  <Paginator pages={ this.state.pagination } pageData={ this.pageData }/>
                </td>
              </tr>
            </tfoot>
            <tbody>
              { rows }
            </tbody>
          </table>
        }
      </div>
    );
  }
});
