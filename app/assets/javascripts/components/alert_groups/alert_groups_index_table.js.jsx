var AlertGroupResultRow = React.createClass({
  render: function() {
    return (
    <tr data-href={alert.viewLink}>
      <td>{this.props.alert.name}</td>
      <td>{this.props.alert.description}</td>
      <td>{this.props.alert.enabled}</td>
      <td>{this.props.alert.sites}</td>
      <td>{this.props.alert.roles}</td>
      <td>{this.props.alert.lastIncident}</td>
    </tr>);
  }
});

var AlertGroupsIndexTable = React.createClass({
  getDefaultProps: function() {
    return {
      allowSorting: true,
      orderBy: 'alerts.name'
    }
  },

  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var rows           = [];
    var sortableHeader = function (title, field, tooltipText) {
      return <SortableColumnHeaderWithTooltip title={title} field={field} orderBy={this.props.orderBy} tooltipText={tooltipText} />
    }.bind(this);

    this.props.alerts.forEach(
      function(alert) {
        rows.push(<AlertGroupResultRow key={alert.id} alert={alert} />);
      }
    );

    return (
      <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="alert-groups-table">
        <thead>
          <tr>
            {sortableHeader('Name', 'alerts.name', 'This is the Name of the Alert.')}
            {sortableHeader('Description', 'alerts.description', 'A meaningful description about what the alert entails.')}
            {sortableHeader('Enabled', 'alerts.enabled', 'Is this alert enabled?')}
            <th data-resizable-column-id="alerts.sites">
              <div className="tooltip">
                Sites
                <div className="tooltiptext_r">
                  Which site(s) this alert will trigger for.
                </div>
              </div>
            </th>
            <th data-resizable-column-id="alerts.roles">
              <div className="tooltip">
                Roles
                <div className="tooltiptext_r">
                  Something about roles.
                </div>
              </div>
            </th>
            <th data-resizable-column-id="alerts.last_incident">
              <div className="tooltip">
                Last incident
                <div className="tooltiptext_r">
                  When the last incident was reported.
                </div>
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
          {rows}
        </tbody>
      </table>
    );
  }
});
