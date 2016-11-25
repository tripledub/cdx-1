var AuditUpdate = React.createClass({
  navigateTo: function (toUrl) {
    window.location = toUrl;
  },

  render: function(){
    return (
      <tr>
        <td className="audit_presenter">{this.props.auditUpdate.fieldName.replace('_', ' ')}</td>
        <td className="audit_presenter">{this.props.auditUpdate.oldValue.replace('_', ' ')}</td>
        <td className="audit_presenter">{this.props.auditUpdate.newValue.replace('_', ' ')}</td>
      </tr>
    );
  }
});
