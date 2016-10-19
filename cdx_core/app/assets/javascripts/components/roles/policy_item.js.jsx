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
            {I18n.t("components.policy_item.new_policy")}
            <img src="/img/ic-cross.png" className="pull-right" onClick={this.remove} />
          </div>
          <div className="description">{I18n.t("components.policy_item.description_msg")}</div>
        </div>
      );
    } else {
      var withSubsites = "";
      if(statement.includeSubsites) {
        if(statement.resourceType == "site") {
          withSubsites = I18n.t("components.policy_item.and_subsites");
        } else {
          withSubsites = I18n.t("components.policy_item.at_site_and_subsites");
        }
      }
      var inherits = _.find(statement.actions, function(action) { return action.id == '*' });
      var description = null;
      if (inherits) {
        description = inherits.label;
      } else {
        var actions = _.filter(statement.actions, function(action) { return action.resource == statement.resourceType });
        if(actions.length == 0) {
          description = I18n.t("components.policy_item.no_actions_granted");
        } else {
          description = _.map(actions, function(action) { return action.label; }).join(", ");
        }
      }
      return (
        <div>
          <div className="resource-type">
            {statement.resourceType == 'encounter' ? I18n.t("components.policy_item.encounter") : statement.resourceType}{withSubsites}
            <img src="/img/ic-corss.png" className="pull-right" onClick={this.remove} />
          </div>
          <div className="description">{description}</div>
        </div>
      );
    }
  },
});
