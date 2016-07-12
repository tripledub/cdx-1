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

  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy={this.props.orderBy} />
    }.bind(this);

    return (

      <table className="table" cellPadding="0" ref="sortableTable" cellSpacing="0" data-resizable-columns-id="devices-table">
        <thead>
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
