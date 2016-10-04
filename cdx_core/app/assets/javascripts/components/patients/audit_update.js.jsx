var AuditUpdate = React.createClass({
  navigateTo: function (toUrl) {
    window.location = toUrl;
  },

  render: function(){
    return (
      <tr>
        <td className="audit_presenter">{this.props.auditUpdate.fieldName}</td>
        <td className="audit_presenter">{this.props.auditUpdate.oldValue}</td>
        <td className="audit_presenter">{this.props.auditUpdate.newValue}</td>
      </tr>
    );
  }
});
