var ApprovalTable = React.createClass({
  getDefaultProps: function() {
    window.store.get('selectedItems') ? null : window.store.set('selectedItems', '');
    return {
      title: "Test orders",
      allowSorting: true,
      orderBy: "encounters.start_time"
    }
  },

  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  selectedTestOrders: function(selectAll) {
    var selectedItems = '';
    if (selectAll) {
      window.store.set('selectedItems', '');
    } else {
      $('.table input:checked').each(function(element) {
        selectedItems += $(this).attr('name') + ',';
      });
      selectedItems = selectedItems.slice(0, -1)
      window.store.set('selectedItems', selectedItems);
    }
  },

  requestCsvFile: function () {
    window.location = this.props.csvUrl + '&format=csv&selectedItems=' + window.store.get('selectedItems')
  },

  render: function() {
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy={this.props.orderBy} />
    }.bind(this);

    return (
      <div className="small-12 columns box">
        <header>
          <img src={this.props.imageUrl} alt={this.props.headerTitle} />
          <h3>
            {this.props.headerTitle}
          </h3>
          <span className="table-actions">
            <a title={this.props.csvTitle} onClick={this.requestCsvFile} href="#">
              <span className="icon-download icon-gray"></span>
            </a>
          </span>
        </header>
        <div className="box-content">
          <table className="table testOrdersTable" cellPadding="0" cellSpacing="0"  data-resizable-columns-id="approvals-table">
            <thead>
              <tr>
                <CsvCheckboxColumnHeader columnId="approvals-table" selectedTestOrders={this.selectedTestOrders} />
                <th data-resizable-column-id="sample-id">{I18n.t("components.test_orders.col_sample_id")}</th>
                {sortableHeader(I18n.t("components.test_orders.col_status"),        "encounters.status")}
                {sortableHeader(I18n.t("components.test_orders.col_request_by"),    "sites.name")}
                {sortableHeader(I18n.t("components.test_orders.col_request_to"),    "performing_sites.name")}
                {sortableHeader(I18n.t("components.test_orders.col_testing_for"),   "patients.name")}
                {sortableHeader(I18n.t("components.test_orders.col_order_by"), "users.first_name")}
                {sortableHeader(I18n.t("components.test_orders.col_request_date"),  "encounters.start_time")}
                <th data-resizable-column-id="tests-requiring-approval">{I18n.t("components.test_orders.col_tests_requiring_approval")}</th>
                {sortableHeader(I18n.t("components.test_orders.col_id"),      "encounters.uuid")}

              </tr>
            </thead>
            <tbody>
              {this.props.testOrders.map(function(testOrder) {
                 return <ApprovalRow key={testOrder.id} testOrder={testOrder} selectedTestOrders={this.selectedTestOrders} />;
              }.bind(this))}
            </tbody>
          </table>
        </div>
      </div>

    );
  }
});
