var IntegrationButton = React.createClass({
  getDefaultProps: function(){
    return {
      value: I18n.t("components.integration_logs.retry")
    }
  },
  
  handleClick: function(event){
    // handle manually retry integration here
    var log_id = this.props.id;
    $.ajax({
      url: "/integration_logs/retry?id=" + log_id,
      type: 'GET',
      dataType: 'json',
      success: function(data) {
        window.alert("success");
      },
      error: function(xhr, status, err) {
        window.alert(err.toString());
      }
    });
  },
  
  render: function(){
    return (
      <a href="" className="btn-primary" onClick={this.handleClick.bind(this)}>{this.props.value}</a>
    )
  }  
});

var IntegrationLogRow = React.createClass({
  render: function() {
    var that = this;
    var retry = "";
    if (this.props.record.status != "Finished")
    {
      retry = <IntegrationButton id={this.props.record.id} />;
    }

    return (
    <tr data-href={this.props.record.id}>
      <td>{this.props.record.patientName}</td>
      <td>{this.props.record.orderId}</td>
      <td>{this.props.record.failStep}</td>
      <td>{this.props.record.system}</td>
      <td>{this.props.record.errorMessage}</td>
      <td>{this.props.record.tryNTimes}</td>
      <td>{this.props.record.status}</td>
      <td>{this.props.record.updatedDate}</td>
      <td>{retry}</td>
    </tr>);
  }
});

var IntegrationLogsIndexTable = React.createClass({
  getDefaultProps: function() {
    return {
      title: I18n.t("components.integration_logs.col_title"),
      allowSorting: true,
      orderBy: "integration_logs.updated_at"
    }
  },

  render: function() {
    var rows = [];
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy={this.props.orderBy} />
    }.bind(this);    

    this.props.logs.forEach(
      function(record) {
        rows.push(<IntegrationLogRow key={record.id} record={record}/>);
      }.bind(this)
    );

    return (
      <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="integration_logs-table">
        <thead>
          <tr>
            {sortableHeader(I18n.t("components.integration_logs.col_patient_name"), "integration_logs.patient_name")}
            {sortableHeader(I18n.t("components.integration_logs.col_order_id"), "integration_logs.order_id")}
            {sortableHeader(I18n.t("components.integration_logs.col_fail_step"), "integration_logs.fail_step")}
            {sortableHeader(I18n.t("components.integration_logs.col_system"), "integration_logs.system")}
            {sortableHeader(I18n.t("components.integration_logs.col_error_message"), "integration_logs.error_message")}
            {sortableHeader(I18n.t("components.integration_logs.col_try_n_times"), "integration_logs.try_n_times")}
            {sortableHeader(I18n.t("components.integration_logs.col_status"), "integration_logs.status")}
            {sortableHeader(I18n.t("components.integration_logs.col_updated_at"), "integration_logs.updated_at")}
            {sortableHeader(I18n.t("components.integration_logs.retry"), "integration_logs.updated_at")}
          </tr>
        </thead>
        <tbody>
          {rows}
        </tbody>
      </table>
    );
  }
});
