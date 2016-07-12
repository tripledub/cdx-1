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
      <section className="row">
        <div className="small-12 columns box">
          <header>
            <img src="/assets/img/test-tube-rack-5b3580a9d8fc54b5cf7bd4ca808fb86c.png" alt="Test tube rack" />
            <h3>{this.props.title}</h3>
            { this.props.downloadCsvPath ? (
              <span className="table-actions">
                <a href={this.props.downloadCsvPath} title="Download CSV">
                  <span className="icon-download icon-gray"></span>
                </a>
              </span>) : null }
          </header>
          <div className="box-content">
            <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="devices-table">
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
          </div>
        </div>
      </section>
    );
  }
});
