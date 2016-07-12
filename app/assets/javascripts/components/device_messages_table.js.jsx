var DeviceMessageRow = React.createClass({
  render: function() {
    return (
    <tr>
      <td>
        {
          this.props.deviceMessage.indexStatus.hasOwnProperty('success') ?
          this.props.deviceMessage.indexStatus.success :
          <a href={this.props.deviceMessage.indexStatus.link} title="Click to reprocess this message again" method="post">
            {this.props.deviceMessage.indexStatus.failed}
          </a>
        }</td>
      <td>{this.props.deviceMessage.failureReason}</td>
      <td>{this.props.deviceMessage.modelName}</td>
      <td>{this.props.deviceMessage.deviceName}</td>
      <td>{this.props.deviceMessage.numberOfFailures}</td>
      <td>{this.props.deviceMessage.errorField}</td>
      <td>{this.props.deviceMessage.createdAt}</td>
      <td>
        <a href={this.props.deviceMessage.rawLink} title="Download raw file">
          <div className="icon-download icon-gray"></div>
        </a>
      </td>
    </tr>);
  }
});

var DeviceMessagesList = React.createClass({
  getDefaultProps: function() {
    return {
      title: "Device messages",
      titleClassName: "table-title",
      allowSorting: true,
      orderBy: "-device_messages.created_at"
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
            </th>
          </tr>
          <tr>
            {sortableHeader("Status",  "device_messages.index_failed")}
            {sortableHeader("Message", "device_messages.index_failure_reason")}
            {sortableHeader("Model",   "device_models.name")}
            {sortableHeader("Device",  "devices.name")}
            <th>Failures</th>
            <th>Error field</th>
            {sortableHeader("Date",    "device_messages.created_at")}
            <th>Raw</th>
          </tr>
        </thead>
        <tbody>
          {this.props.deviceMessages.map(function(deviceMessage) {
             return <DeviceMessageRow key={deviceMessage.id} deviceMessage={deviceMessage} />;
          }.bind(this))}
        </tbody>
      </table>
    );
  }
});
