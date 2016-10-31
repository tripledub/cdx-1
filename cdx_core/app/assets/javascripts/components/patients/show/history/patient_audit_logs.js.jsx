var PatientAuditLogs = React.createClass({
  getInitialState: function() {
    return {
      patientLogs: [],
      orderBy: this.props.defaultLogsOrder,
      pagination: {},
      pageNumber: 1,
      loadingMessage: I18n.t("components.patients.show.history.msg_loading"),
      availableColumns: [
        { title: I18n.t("components.patients.show.history.col_title"),  fieldName: 'audit_logs.title' },
        { title: I18n.t("components.patients.show.history.col_user"),   fieldName: 'users.first_name' },
        { title: I18n.t("components.patients.show.history.col_device"), fieldName: 'devices.name' },
        { title: I18n.t("components.patients.show.history.col_date"),   fieldName: 'audit_logs.created_at' }
      ]
    };
  },

  getData: function(field, pageNumber, event) {
    if (event) { event.preventDefault(); }
    this.serverRequest = $.get(this.props.patientLogsUrl + this.getParams(field, pageNumber), function (results) {
      if (results['rows'].length > 0) {
        this.setState({ pagination: results['pages'] });
        this.setState({ patientLogs: results['rows'] });
        this.setState({ orderBy: results['order_by'] });
        $("table").resizableColumns({store: window.store});
      } else {
        this.setState({ loadingMessage: I18n.t("components.patients.show.history.msg_no_log") });
      };
    }.bind(this));
  },

  pageData: function(pageNumber) {
    this.getData(this.state.activeField, pageNumber);
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

  render: function(){
    var rows       = [];
    var rowHeaders = [];
    var that       = this;
    this.state.patientLogs.forEach(
      function(patientLog) {
        rows.push(<PatientLog patientLog={ patientLog } key={ patientLog.id } />);
      }
    );

    this.state.availableColumns.forEach(
      function(availableColumn) {
        rowHeaders.push(
          <OrderedColumnHeader key={ availableColumn.fieldName } title={ availableColumn.title } fieldName={ availableColumn.fieldName } orderEvent={ that.getData } orderBy={ that.state.orderBy } />
        );
      }
    );
    return (
      <div className="row">
        {
          this.state.patientLogs.length < 1 ? <LoadingResults loadingMessage={ this.state.loadingMessage } /> :
          <table className="table patient-audit-logs" data-resizable-columns-id="patient-audit-logs">
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
              {rows}
            </tbody>
          </table>
        }
      </div>
    );
  }
});
