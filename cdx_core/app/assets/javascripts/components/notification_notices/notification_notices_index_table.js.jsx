var NotificationNoticeRow = React.createClass({
  render: function() {
    return (
    <tr data-href={this.props.notificationNotice.viewLink}>
      <td>{this.props.notificationNotice.notification}</td>
      <td>{this.props.notificationNotice.date}</td>
      <td>{this.props.notificationNotice.status}</td>
      <td>{this.props.notificationNotice.message}</td>
    </tr>);
  }
});

var NotificationNoticesIndexTable = React.createClass({
  getDefaultProps: function() {
    return {
      allowSorting: true,
      orderBy: "notification_notices.created_at",
    }
  },

  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var rows           = [];
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy={this.props.orderBy} />
    }.bind(this);

    this.props.notificationNotices.forEach(
      function(notificationNotice) {
        rows.push(<NotificationNoticeRow key={notificationNotice.id} notificationNotice={notificationNotice} />);
      }
    );

    return (
      <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="alert-messages-table">
        <thead>
          <tr>
            {sortableHeader(I18n.t("components.notification_notices.col_name"), "notifications.name")}
            {sortableHeader(I18n.t("components.notification_notices.col_date"), "notification_notices.created_at")}
            {sortableHeader(I18n.t("components.notification_notices.col_status"), "notification_notices.status")}
            {sortableHeader(I18n.t("components.notification_notices.col_message"), "notification_notices.message")}
          </tr>
        </thead>
        <tbody>
          {rows}
        </tbody>
      </table>
    );
  }
});
