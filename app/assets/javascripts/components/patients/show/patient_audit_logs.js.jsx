var PatientAuditLogs = React.createClass({
  getInitialState: function() {
    return {
      patientLogs: [],
      queryOrder: true,
      loadingMessasge: 'Loading logs...',
      defaultOrder: { 'title': '', 'user': '', 'date': '' },
      orderedColumns: {},
      availableColumns: [
        { title: 'Title',      fieldName: 'title' },
        { title: 'User',       fieldName: 'user' },
        { title: 'Date added', fieldName: 'date' }
      ]
    };
  },

  getPatientLogs: function(field, e) {
    if (e) { e.preventDefault(); }
    this.serverRequest = $.get(this.props.patientLogsUrl + this.getParams(field), function (results) {
      if (results.length > 0) {
        this.setState({ patientLogs: results });
        this.updateOrderIcon(field)
      } else {
        this.setState({ loadingMessage: 'There are no logs available.' });
      };
    }.bind(this));
  },

  getParams: function(field) {
    this.state.queryOrder = !this.state.queryOrder;
    return '&field='+ field + '&order=' + this.state.queryOrder;
  },

  updateOrderIcon: function(orderedField) {
    iconValue                  = (this.state.queryOrder == true) ? '&#x25BC;' : '&#x25B2;';
    updatedState               = this.state.defaultOrder;
    updatedState[orderedField] = iconValue;
    this.setState({ orderedColumns: updatedState });
  },

  componentDidMount: function() {
    this.getPatientLogs('date');
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
        rows.push(<PatientLog patientLog={patientLog} key={patientLog.id} />);
      }
    );

    this.state.availableColumns.forEach(
      function(availableColumn) {
        rowHeaders.push(<OrderedColumnHeader key={availableColumn.fieldName} title={availableColumn.title} fieldName={availableColumn.fieldName} orderEvent={that.getPatientLogs} orderIcon={that.state.orderedColumns[availableColumn.fieldName]} />);
      }
    );

    return (
      <div className="row">
        {
          this.state.patientLogs.length < 1 ? <LoadingResults loadingMessage={this.state.loadingMessage} /> :
          <table className="patient-audit-logs">
            <thead>
              <tr>
               {rowHeaders}
              </tr>
            </thead>
            <tbody>
              {rows}
            </tbody>
          </table>
        }
      </div>
    );
  }
});
