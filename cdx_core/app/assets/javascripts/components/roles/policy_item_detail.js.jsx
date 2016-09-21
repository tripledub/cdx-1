var PolicyItemDetail = React.createClass({
  selectableResources: function() {
    return ['device', 'testResult', 'encounter'];
  },

  idFor: function(name) {
    return name + "-" + this.props.index;
  },

  toggleDelegable: function() {
    this.props.updateStatement({delegable: { $apply: function(current) { return !current; } }});
  },

  onResourceTypeChange: function(newValue) {
    var data = {resourceType: { $set: newValue }};
    if(!_.includes(this.selectableResources(), newValue)) {
      data.statementType = { $set: 'all'};
    };
    this.props.updateStatement(data);
  },

  toggleIncludeSubsites: function() {
    this.props.updateStatement({includeSubsites: { $apply: function(current) { return !current; } }});
  },

  onStatementTypeChange: function(selected) {
    this.props.updateStatement({statementType: { $set: selected}});
  },

  toggleAction: function(action) {
    this.props.updateStatement({
      actions: {
        $apply: (function(actions) {
          actions = actions.slice(); // clone the list - so we don't modify the original one
          var actionIndex = actions.indexOf( actions.find(function(anAction) { return anAction.id == action.id }) );
          if(actionIndex < 0) {
            actions.push(action); // add
            $('[key!="all"]').prop('enabled',false);
          } else {
            actions.splice(actionIndex, 1); // remove
            $('[key!="all"]').prop('enabled',true);
          }
          return actions;
        }).bind(this)
      }
    });
  },

  statementHasAction: function(statement, action) {
    return _.find(statement.actions, function(anAction) { return anAction.id == action.id });
  },

  removeResourceAtIndex: function(resourceIndex) {
    this.props.updateStatement({resourceList: {[this.props.statement.statementType] : {$splice: [[resourceIndex, 1]]} } })
  },

  addResource: function(resource) {
    if(this.props.statement.resourceList[this.props.statement.statementType].findIndex(function(aResource) {
      return aResource.uuid == resource.uuid;
    }) < 0) {
      this.props.updateStatement({resourceList: {[this.props.statement.statementType] : {$push: [resource]}}})
    }
  },

  resourcesLabel: function() {
    var currentResourceType = _.find(this.props.resourceTypes, (function(resourceType) { return resourceType.value == this.props.statement.resourceType }).bind(this));
    return (currentResourceType.label + "s").toLowerCase();
  },

  render: function() {
    var statement = this.props.statement;
    var resourcesList = {
      "except": <div className="without-statement-type-except-list" />,
      "only": <div className="without-statement-type-only-list" />
    }
    var ifResourceTypeSelected = <div className="without-resource-type" />;
    var ifResourcesSelectable = "";
    if (statement.resourceType != null) {
      var actions = this.props.actions[statement.resourceType];
      var resourcesLabel = this.resourcesLabel();

      // FIXME: filter resources for other types - ie, 'site'
      if(_.includes(this.selectableResources(), statement.resourceType)) {
        if (_.includes(['institution', 'site'], _.get(statement, ['resourceList', statement.statementType, 0, 'type']))) {
          // HACK for statements scoped for institution
          ifResourcesSelectable = (<div className="row section">
            <div className="col px-1">
              <label className="section-name">{I18n.t("components.policy_item_detail.resources_label")}</label>
            </div>
            <div className="col">
              <input type="radio" name="statementType" value="all" id={this.idFor("statement-type-all")} checked={true} readOnly={true} />
              <label htmlFor={this.idFor("statement-type-all")}>{I18n.t("components.policy_item_detail.all_text")} {resourcesLabel} {I18n.t("components.policy_item_detail.from_text")} {statement.resourceList[statement.statementType][0].name}</label>
            </div>
          </div>);
        } else {
          // TODO: replace DeviceList with OptionList
          resourcesList[statement.statementType] = <div className={"with-statement-type-" + statement.statementType + "-list"}><DeviceList devices={statement.resourceList[statement.statementType]} addDevice={this.addResource} removeDevice={this.removeResourceAtIndex} context={this.props.context} isException={statement.statementType == 'except'} /></div>;

          ifResourcesSelectable = (<div className="row section">
            <div className="col px-1">
              <label className="section-name">{I18n.t("components.policy_item_detail.resources_label")}</label>
            </div>
            <div className="col">
              <div className="section-content">
                <input type="radio" name="statementType" value="all" id={this.idFor("statement-type-all")} checked={statement.statementType == 'all'} onChange={this.onStatementTypeChange.bind(this, 'all')} />
                <label htmlFor={this.idFor("statement-type-all")}>{I18n.t("components.policy_item_detail.all_text")} {resourcesLabel}</label>
                <input type="radio" name="statementType" value="except" id={this.idFor("statement-type-except")} checked={statement.statementType == 'except'} onChange={this.onStatementTypeChange.bind(this, 'except')} />
                <label htmlFor={this.idFor("statement-type-except")}>{I18n.t("components.policy_item_detail.all_text")} {resourcesLabel} except</label>
                {resourcesList['except']}
                <input type="radio" name="statementType" value="only" id={this.idFor("statement-type-only")} checked={statement.statementType == 'only'} onChange={this.onStatementTypeChange.bind(this, 'only')} />
                <label htmlFor={this.idFor("statement-type-only")}>{I18n.t("components.policy_item_detail.only_some_text")} {resourcesLabel}</label>
                {resourcesList['only']}
              </div>
            </div>
          </div>);
        }
      }

      var actions = this.props.actions[statement.resourceType];
      var allAction = {id: '*', label: 'All', value: '*'};
      var resourcesLabel = this.resourcesLabel();
      var hasAllAction = this.statementHasAction(statement, allAction);

      ifResourceTypeSelected = <div className="with-resource-type">
        {ifResourcesSelectable}
        <div className="row section">
          <div className="col px-1">
            <label className="section-name">{I18n.t("components.policy_item_detail.actions_label")}</label>
          </div>
          <div className="col">
            <div className="section-content">
              <div key="all">
                <input type="checkbox" id={this.idFor("action-all")} checked={hasAllAction} onChange={this.toggleAction.bind(this, allAction)} />
                <label htmlFor={this.idFor("action-all")}>{I18n.t("components.policy_item_detail.all_text")}</label>
              </div>
              { Object.keys(actions).map(function(actionKey, index) {
                var action = actions[actionKey];
                return (
                  <div key={actionKey}>
                    <input type="checkbox" id={this.idFor("action-" + actionKey)} checked={this.statementHasAction(statement, action)} onChange={this.toggleAction.bind(this, action)} disabled={hasAllAction} />
                    <label htmlFor={this.idFor("action-" + actionKey)}>{action.label}</label>
                  </div>
                );
              }.bind(this)) }
            </div>
          </div>
        </div>
      </div>;
    }
    return (
      <div>
        <div className="row section">
          <div className="col px-1">
            <label className="section-name">{I18n.t("components.policy_item_detail.delegable_label")}</label>
          </div>
          <div className="col">
            <div className="section-content">
              <input type="checkbox" id={this.idFor("delegable")} checked={statement.delegable} onChange={this.toggleDelegable} className="power" />
              <label htmlFor={this.idFor("delegable")}>{I18n.t("components.policy_item_detail.users_can")}{statement.delegable ? "" : I18n.t("components.policy_item_detail.not")} {I18n.t("components.policy_item_detail.delegate_permissions_on_this_policy")}</label>
            </div>
          </div>
        </div>
        <div className="row section">
          <div className="col px-1">
            <label className="section-name">{I18n.t("components.policy_item_detail.type_label")}</label>
          </div>
          <div className="col">
            <div className="section-content">
              <CdxSelect items={this.props.resourceTypes} value={statement.resourceType} onChange={this.onResourceTypeChange} />
              <input type="checkbox" id={this.idFor("includeSubsites")} checked={statement.includeSubsites} onChange={this.toggleIncludeSubsites} />
              <label htmlFor={this.idFor("includeSubsites")}>{I18n.t("components.policy_item_detail.include_subsites_label")}</label>
            </div>
          </div>
        </div>
        {ifResourceTypeSelected}
      </div>
    );
  },

});
