var PolicyItem = React.createClass({
  remove: function(e) {
    e.preventDefault();
    this.props.onRemove(this.props.statement);
  },

  render: function() {
    var statement = this.props.statement;
    if (statement.resourceType == null) {
      return (
        <div>
          <div className="resource-type">
            New Policy
            <img src={Img.assetPath('ic-cross.png')} className="pull-right" onClick={this.remove} />
          </div>
          <div className="description">{I18n.t("components.policy_item.description_msg")}</div>
        </div>
      );
    } else {
      var withSubsites = "";
      if (statement.includeSubsites) {
        if (statement.resourceType == "site") {
          withSubsites = " and subsites";
        } else {
          withSubsites = " at site and subsites";
        }
      }
      var inherits = _.find(statement.actions, function(action) { return action.id == '*' });
      var description = null;
      if (inherits) {
        description = inherits.label;
      } else {
        var actions = _.filter(statement.actions, function(action) { return action.resource == statement.resourceType });
        if (actions.length == 0) {
          description = "No actions granted";
        } else {
          description = _.map(actions, function(action) { return action.label; }).join(", ");
        }
      }
      return (
        <div>
          <div className="resource-type">
            {statement.resourceType}{withSubsites}
            <img src={Img.assetPath('ic-cross.png')} className="pull-right" onClick={this.remove} />
          </div>
          <div className="description">{description}</div>
        </div>
      );
    }
  },

});
