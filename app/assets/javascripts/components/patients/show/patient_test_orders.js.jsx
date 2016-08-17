var PatientTestOrders = React.createClass({
  getInitialState: function() {
    return {
      patientTestOrders: [],
      queryOrder: true,
      loadingMessage: 'Loading test orders...',
      orderedColumns: {},
      availableColumns: [
        { title: 'Request By',    fieldName: 'site' },
        { title: 'Request To',    fieldName: 'performingSite' },
        { title: 'Order Id',      fieldName: 'orderId' },
        { title: 'Order by User', fieldName: 'requester' },
        { title: 'Request Date',  fieldName: 'requestDate' },
        { title: 'Due Date',      fieldName: 'dueDate' },
        { title: 'status',        fieldName: 'status' }
      ]
    };
  },

  getData: function(field, e) {
    if (e) { e.preventDefault(); }
    this.serverRequest = $.get(this.props.testOrdersUrl + this.getParams(field), function (results) {
      if (results.length > 0) {
        this.setState({ patientTestOrders: results });
        this.updateOrderIcon(field);
        $("table").resizableColumns({store: window.store});
      } else {
        this.setState({ loadingMessage: 'There are no test orders.' });
      };
    }.bind(this));
  },

  getParams: function(field) {
    this.state.queryOrder = !this.state.queryOrder;
    return '&field='+ field + '&order=' + this.state.queryOrder;
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
    this.getData('site');
  },

  componentWillUnmount: function() {
    this.serverRequest.abort();
  },

  render: function(){
    var rows = [];
    var rowHeaders = [];
    var that       = this;
    this.state.patientTestOrders.forEach(
      function(patientTestOrder) {
        // Add any on-the-fly field values to the output row
        patientTestOrder._highlight_overdue = '';
        var today = new Date();
        if(patientTestOrder.status_raw != 'completed' && patientTestOrder.dueDate)
        {
          var dd = Date.parse(patientTestOrder.dueDate);
          if(dd < today )
          {
            patientTestOrder._highlight_overdue = 'overdueHightlight';
          }
        }
        rows.push(<PatientTestOrder patientTestOrder={patientTestOrder} key={patientTestOrder.id} />);
      }
    );

    this.state.availableColumns.forEach(
      function(availableColumn) {
        rowHeaders.push(<OrderedColumnHeader key={availableColumn.fieldName} title={availableColumn.title} fieldName={availableColumn.fieldName} orderEvent={that.getData} orderIcon={that.state.orderedColumns[availableColumn.fieldName]} />);
      }
    );

    return (
      <div className="row">
        {
          this.state.patientTestOrders.length < 1 ? <LoadingResults loadingMessage={this.state.loadingMessage} /> :
          <table className="table patient-test-orders" data-resizable-columns-id="patient-test-orders-table">
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
