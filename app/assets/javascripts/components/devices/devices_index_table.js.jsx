var DeviceResultRow = React.createClass({
  render: function() {
    var device = this.props.device;

    return (
    <tr data-href={device.viewLink}>
      <td>{device.name}</td>
      <td>{device.institutionName}</td>
      <td>{device.modelName}</td>
      <td>{device.siteName}</td>
    </tr>);
  }
});

var DevicesIndexTable = React.createClass({
  getDefaultProps: function() {
    return {
      title: "Devices",
      titleClassName: "",
      downloadCsvPath: null,
      allowSorting: false,
      orderBy: "",
      showSites: true,
      showDevices: true
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
            <th className="tableheader" colSpan="12">
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
            {sortableHeader("Name", "devices.name")}
            {sortableHeader("Manufacturer", "institutions.name")}
            {sortableHeader("Model", "device_models.name")}
            {sortableHeader("Site", "sites.name")}
          </tr>
        </thead>
        <tbody>
          {this.props.devices.map(function(device) {
             return <DeviceResultRow key={device.id} device={device} />;
          }.bind(this))}
        </tbody>
      </table>
    );
  }
});
