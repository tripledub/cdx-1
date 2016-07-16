var TestOrderRow = React.createClass({
  render: function() {
    return (
    <tr data-href={this.props.testOrder.viewLink}>
      <td>{this.props.testOrder.requestedSiteName}</td>
      <td>{this.props.testOrder.performingSiteName}</td>
      <td>{this.props.testOrder.sampleId}</td>
      <td>{this.props.testOrder.testingFor}</td>
      <td>{this.props.testOrder.requestedBy}</td>
      <td>{this.props.testOrder.requestDate}</td>
      <td>{this.props.testOrder.dueDate}</td>
      <td>{this.props.testOrder.status}</td>
    </tr>);
  }
});

var TestOrdersList = React.createClass({
  getDefaultProps: function() {
    return {
      title: "Test orders",
      allowSorting: true,
      orderBy: "encounters.testdue_date"
    }
  },

  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy={this.props.orderBy} />
    }.bind(this);

    return (
      <table className="table" cellPadding="0" cellSpacing="0"  data-resizable-columns-id="test-orders-table">
        <thead>
          <tr>
            {sortableHeader("Request by", "sites.name")}
            <th data-resizable-column-id="performing-site">Request to</th>
            <th data-resizable-column-id="sample-id">Sample Id</th>
            {sortableHeader("Testing for",  "patients.name")}
            {sortableHeader("Order by user", "users.first_name")}
            {sortableHeader("Request date", "encounters.start_time")}
            {sortableHeader("Due date",     "encounters.testdue_date")}
            {sortableHeader("Status",       "encounters.status")}
          </tr>
        </thead>
        <tbody>
          {this.props.testOrders.map(function(testOrder) {
             return <TestOrderRow key={testOrder.id} testOrder={testOrder} />;
          }.bind(this))}
        </tbody>
      </table>
    );
  }
});

var TestOrdersIndexTable = React.createClass({
  render: function() {
    return <TestOrdersList testOrders={this.props.tests}
              title={this.props.title} titleClassName="table-title"
              allowSorting={true} orderBy={this.props.orderBy}  />
  }
});
