var PatientAuditLogs = React.createClass({
  getInitialState: function() {
    return {
      patientLogs: [],
      queryOrder: true,
      pagination: {},
      activeField: 'date',
      pageNumber: 1,
      loadingMessasge: I18n.t("components.patients.show.history.msg_loading"),
      orderedColumns: {},
      availableColumns: [
        { title: I18n.t("components.patients.show.history.col_title"),  fieldName: 'title' },
        { title: I18n.t("components.patients.show.history.col_user"),   fieldName: 'user' },
        { title: I18n.t("components.patients.show.history.col_device"), fieldName: 'device' },
        { title: I18n.t("components.patients.show.history.col_date"),   fieldName: 'date' }
      ]
    };
  },

  getData: function(field, pageNumber, e) {
    if (e) { e.preventDefault(); }
    this.serverRequest = $.get(this.props.patientLogsUrl + this.getParams(field, pageNumber), function (results) {
      if (results['rows'].length > 0) {
        this.setState({ pagination: results['pages'] });
        this.setState({ patientLogs: results['rows'] });
        this.updateOrderIcon(field);
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
    let queryOrder = this.state.queryOrder;

    if (!pageNumber) {
      pageNumber = this.state.pageNumber
      queryOrder = !this.state.queryOrder;
      this.setState({ queryOrder: queryOrder });
    };

    this.setState({ activeField: field });
    this.setState({ pageNumber: pageNumber });
    return '&field='+ field + '&order=' + queryOrder + '&page=' + pageNumber;
  },

  updateOrderIcon: function(orderedField) {
    var that                       = this;
    var updatedState               = {};
    var iconValue                  = (this.state.queryOrder == true) ? '&#x25BC;' : '&#x25B2;';
    this.state.availableColumns.forEach(
      function(column) {
        updatedState[column.fieldName] = ''
      }
    );
    updatedState[orderedField] = iconValue;
    this.setState({ orderedColumns: updatedState });
  },

  componentDidMount: function() {
    this.getData('date', this.state.pageNumber);
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
        rowHeaders.push(<OrderedColumnHeader key={ availableColumn.fieldName } title={ availableColumn.title } fieldName={ availableColumn.fieldName } orderEvent={ that.getData } orderIcon={ that.state.orderedColumns[availableColumn.fieldName] } />);
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
