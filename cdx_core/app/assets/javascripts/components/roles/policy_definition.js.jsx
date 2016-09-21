var PolicyDefinition = React.createClass({
  getInitialState: function() {
    return {
      statements: this.policyDefinitionStatements(this.props),
      activeTab: 0
    };
  },

  emptyPolicy: { delegable: false, resourceType: null, includeSubsites: false, actions: [], resourceList: {'except': [], 'only': []} },

  policyDefinitionStatements: function(props) {
    var definition = props.definition;
    if(definition == null) {
      return [this.emptyPolicy];
    }

    definition = JSON.parse(definition);

    var statements = definition.statement.map(function(definitionStatement, index) {

      // ensure delegable is a boolean, and action, resource and except are arrays
      var statement = {
        delegable: definitionStatement.delegable == true,
        includeSubsites: definitionStatement.includeSubsites == true
      };

      ['action', 'resource', 'except'].forEach(function(property) {
        var definitionProperty = definitionStatement[property] || [];
        if(Array.isArray(definitionProperty)) {
          statement[property] = definitionProperty;
        } else if(definitionProperty == null) {
          statement[property] = [];
        } else {
          statement[property] = [definitionProperty];
        }
      });

      var resourceList = {
        'except': [],
        'only': []
      }

      var statementType = null;
      var resources = null;
      var resourceType = null;

      var _resourceComponents = function(resource) {
        var parts;
        if(parts = resource.match(/(.*)\?(.*)\=(.*)/)) {
          // policyType?resourceType=resourceId
          return {
            policyResourceType: parts[1],
            thisResourceType: parts[2],
            thisResourceId: parts[3]
          }
        } else if(parts = resource.match(/(.*)\/(.*)/)) {
          // resourceType/resourceId
          return {
            policyResourceType: parts[1],
            thisResourceType: parts[1],
            thisResourceId: parts[2]
          }
        } else {
          // resourceType - ie, the whole class
          return {
            policyResourceType: resource,
            thisResourceType: resource
          }
        }
      }

      if(statement.except.length > 0) {
        statementType = 'except';
        resources = statement.except;
      } else {
        resources = statement.resource;
        if(resources[0] && _resourceComponents(resources[0]).thisResourceId) {
          statementType = 'only';
        } else {
          statementType = 'all';
          resourceType = resources[0];
        }
      }

      var _hydratateResourceAndCheckType = function(resources, resourceKey) {
        var components = _resourceComponents(resourceKey);

        if(!resourceType) {
          resourceType = components.policyResourceType;
        }
        if(components.policyResourceType != resourceType) {
          // FIXME - show this warnings to the user
          console.warn("Resource type " + components.policyResourceType + " doesn't match previous resource's type " + resourceType +
              " - the control may not work OK");
        }
        return resources[resourceKey];
      }

      if(_.includes(['only', 'except'], statementType)) {
        resourceList[statementType] = resources.map(_hydratateResourceAndCheckType.bind(this, props.resources));
      }

      var _hydratateAction = function(actions, action) {
        if (action == '*') {
          return {id: '*', label: 'All', value: '*'};
        }
        var components = action.split(":");
        return actions[components[0]][components[1]];
      }

      return {
        id: index,
        delegable: statement.delegable == true,
        includeSubsites: statement.includeSubsites == true,
        actions: statement.action.map(_hydratateAction.bind(this, props.actions)),
        resourceList: resourceList,
        resourceType: resourceType,
        statementType: statementType
      };
    });

    if(statements.length == 0) {
      return [this.emptyPolicy];
    } else {
      return statements;
    }
  },

  newPolicy: function() {
    var newEmptyPolicy = { delegable: false, resourceType: null, includeSubsites: false, actions: [], resourceList: {'except': [], 'only': []} };
    newEmptyPolicy.id  = this.state.statements.length;
    this.setState(React.addons.update(this.state, {
      statements: { $push: [newEmptyPolicy] },
      activeTab: { $set: this.state.statements.length } // the new statement isn't on the array yet
    }));
  },

  updateStatement: function(index, changes) {
    this.setState(React.addons.update(this.state, {
      statements: {
        // TODO - check non-Chrome browsers compatibility (keyword: ES2015 dynamic indexes/keys)
        [index]: changes
      }
    }))
  },

  setActiveTab: function(index) {
    this.setState(React.addons.update(this.state, {
      activeTab: { $set: index }
    }));
  },

  _removeStatement: function(statement) {
    var currentStatements = this.state.statements;
    var index = _.indexOf(this.state.statements, statement);

    currentStatements.splice(index, 1);
    this.setState({statements: currentStatements, activeTab: 0});
  },

  render: function() {
    return (
      <div>
        <PolicyDefinitionField name="role[definition]" statements={this.state.statements} />
        <div className="row items-editor">
          <div className="col px-4">
            <div className="fix">
              <ul>
                {this.state.statements.map(function(statement, index){

                  var selectedClass = this.state.activeTab == index ? "selected" : "";
                  return <li key={index} onClick={this.setActiveTab.bind(this,index)} className={selectedClass}><PolicyItem statement={statement} onRemove={this._removeStatement} /></li>;
                }.bind(this))}
                <li><a onClick={this.newPolicy} href="javascript:" className="btn-add-link"><span className="icon-circle-plus icon-blue"></span>{I18n.t("components.policy_definition.add_policy_btn")}</a></li>
              </ul>
            </div>
          </div>
          <div className="col">
            <div className="items-content selected">
              { this.state.statements[this.state.activeTab] != null ?
                <PolicyItemDetail statement={this.state.statements[this.state.activeTab]} index={this.state.activeTab} updateStatement={this.updateStatement.bind(this, this.state.activeTab)} actions={this.props.actions} resourceTypes={this.props.resourceTypes} context={this.props.context} />
                : null
              }
            </div>
          </div>
        </div>
      </div>
    )
  }
});
