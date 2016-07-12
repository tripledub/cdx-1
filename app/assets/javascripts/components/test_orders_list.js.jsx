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
      titleClassName: "",
      downloadCsvPath: null,
      allowSorting: false,
      orderBy: "encounters.testdue_date",
      showSites: true
    }
  },

  render: function() {
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy={this.props.orderBy} />
    }.bind(this);

    return (
      <table className="table" cellPadding="0" cellSpacing="0">
        <thead>
          <tr>
            <th className="tableheader" colSpan="8">
              <span className={this.props.titleClassName}>{this.props.title}</span>

              { this.props.downloadCsvPath ? (
                <span className="table-actions">
                  <a href={this.props.downloadCsvPath} title="Download CSV">
                    <span className="icon-download icon-gray" />
                  </a>
                </span>) : null }
            </th>
          </tr>
          <tr>
            {sortableHeader("Requested site", "sites.name")}
            <th>Performing site</th>
            <th>Sample Id</th>
            {sortableHeader("Testing for",  "patients.name")}
            {sortableHeader("Requested by", "users.first_name")}
            {sortableHeader("Request date", "encounters.start_time")}
            {sortableHeader("Due date",     "encounters.testdue_date")}
            {sortableHeader("Status",       "encounters.status")}
          </tr>
        </thead>
        <tbody>
          {this.props.testOrders.map(function(testOrder) {
             return <TestOrderRow key={testOrder.uuid} testOrder={testOrder} />;
          }.bind(this))}
        </tbody>
      </table>
    );
  }
});

var TestOrdersIndexTable = React.createClass({
  render: function() {
    return <TestOrdersList testOrders={this.props.tests}
              downloadCsvPath={this.props.downloadCsvPath}
              title={this.props.title} titleClassName="table-title"
              allowSorting={true} orderBy={this.props.orderBy}
              showSites={this.props.showSites} showDevices={this.props.showDevices} />
  }
});
