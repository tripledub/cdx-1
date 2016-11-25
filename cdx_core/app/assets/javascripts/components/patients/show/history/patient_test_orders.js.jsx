var PatientTestOrders = React.createClass({
  getInitialState: function() {
    return {
      patientTestOrders: [],
      orderBy: this.props.defaultOrdersOrder,
      pagination: {},
      pageNumber: 1,
      loadingMessage: I18n.t("components.patients.show.msg_loading"),
      availableColumns: [
        { title: I18n.t("components.patients.show.history.col_test_order_request_by"),      fieldName: 'sites.name' },
        { title: I18n.t("components.patients.show.history.col_test_order_request_to"),      fieldName: 'performing_sites.name' },
        { title: I18n.t("components.patients.show.history.col_test_order_id"),              fieldName: 'encounters.id' },
        { title: I18n.t("components.patients.show.history.col_test_order_by_user"),         fieldName: 'users.first_name' },
        { title: I18n.t("components.patients.show.history.col_test_order_request_date"),    fieldName: 'encounters.start_time' },
        { title: I18n.t("components.patients.show.history.col_test_order_due_date"),        fieldName: 'encounters.testdue_date' },
        { title: I18n.t("components.patients.show.history.col_test_order_status"),          fieldName: 'encounters.status' }
      ]
    };
  },

  getData: function(field, e) {
    if (e) { e.preventDefault(); }
    this.serverRequest = $.get(this.props.testOrdersUrl + this.getParams(field), function (results) {
      if (results['rows'].length > 0) {
        this.setState({ pagination: results['pages'] });
        this.setState({ patientTestOrders: results['rows'] });
        this.setState({ orderBy: results['order_by'] });
        $("table").resizableColumns({store: window.store});
      } else {
        this.setState({ loadingMessage: I18n.t("components.patients.show.msg_no_order") });
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

  render: function(){
    var rows = [];
    var rowHeaders = [];
    var that       = this;
    this.state.patientTestOrders.forEach(
      function(patientTestOrder) {
        // Add any on-the-fly field values to the output row
        patientTestOrder._highlight_overdue = '';
        var today = new Date();
        if(patientTestOrder.statusRaw != 'completed' && patientTestOrder.dueDate)
        {
          var dd = Date.parse(patientTestOrder.dueDate);
          if(dd < today )
          {
            patientTestOrder._highlight_overdue = 'overdueHightlight';
          }
        }
        rows.push(<PatientTestOrder patientTestOrder={ patientTestOrder } key={ patientTestOrder.id } />);
      }
    );

    this.state.availableColumns.forEach(
      function(availableColumn) {
        rowHeaders.push(<OrderedColumnHeader key={ availableColumn.fieldName } title={ availableColumn.title } fieldName={ availableColumn.fieldName } orderEvent={that.getData} orderBy={ that.state.orderBy } />);
      }
    );

    return (
      <div className="row">
        {
          this.state.patientTestOrders.length < 1 ? <LoadingResults loadingMessage={ this.state.loadingMessage } /> :
          <table className="table patient-test-orders" data-resizable-columns-id="patient-test-orders-table">
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
