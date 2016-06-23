var AuditUpdate = React.createClass({
  navigateTo: function (toUrl) {
    window.location = toUrl;
  },

  render: function(){
    return (
      <tr>
        <td>{this.props.auditUpdate.fieldName}</td>
        <td>{this.props.auditUpdate.oldValue}</td>
        <td>{this.props.auditUpdate.newValue}</td>
      </tr>
    );
  }
});
