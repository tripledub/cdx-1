var AlertDelete = React.createClass({
  getInitialState: function() {
    return {
      displayConfirm: false
    };
  },
  clickHandler: function() {
    this.setState({
      displayConfirm: true
    });
  },
  cancelDeleteClickHandler: function() {
    this.setState({
      displayConfirm: false
    });
  },
  confirmClickHandler: function() {
    this.props.onChangeParentLevel();
  },
  render: function() {
    if (this.state.displayConfirm==true) {
      return (
        <ConfirmationModal message= {'You are about to permanently delete this alert. Are you sure you want to proceed?'} title= {'Delete confirmation'} cancel_target= {this.cancelDeleteClickHandler} target= {this.confirmClickHandler} deletion= {true} hideCancel= {false} confirmMessage= {'Delete'} />
      );
    }
    else
    if(this.props.edit) {
      return (
        <div>
          <a className = "btn-secondary pull-right" onClick={this.clickHandler} id="delete_alert" href="#">Delete Alert</a>
        </div>
    );
  } else {
    return null;
  }
}
});



var AlertEnabled = React.createClass({
  render: function() {
    return (
      <div className = "row">
      <div className = "col pe-2">
        <label className="tooltip">Enabled
          <div className="tooltiptext_r">Is this Alert Enabled?</div>
        </label>
      </div>
      <div className = "col">
        <input
          type = "checkbox"
          checkedLink = {
            this.props.checkedLink
          }
          id="AlertEnabled"
          />
        <label htmlFor="AlertEnabled">&nbsp;</label>
      </div>
    </div>
  );
}
});


var AlertName = React.createClass({
  render: function() {
    return (
      <div className = "row" id = "namerow" >
      <div className = "col pe-2" >
        <label className="tooltip">Name
          <div className="tooltiptext_r">Descriptive Name for this Alert</div>
        </label>
      </div>

      <div className = "col" >
        <input type = "text" size="34" placeholder = "Name" valueLink = {
            this.props.valueLink
          }
          id = "alertname" required  pattern=".{2,255}" />
      </div>
    </div>
  );
}
});

var AlertDescription = React.createClass({
  render: function() {
    return (
      <div className = "row" >
      <div className = "col pe-2" >
        <label className="tooltip">Description
          <div className="tooltiptext_r">Short description of the purpose of this Alert</div>
        </label>
      </div>
      <div className = "col" >
        <input type = "text" size="34" placeholder = "Description" valueLink = {
            this.props.valueLink
          }
          id = "alertdescription" />
      </div>
    </div>
  );
}
});


var AlertErrorCode = React.createClass({
  render: function() {
    return (
      <div className = "row" id="errorCodeRow">
      <div className = "col pe-2">
        <label className="tooltip">Errors
          <div className="tooltiptext_r">Range of Error Codes</div>
        </label>
      </div>

      <div className = "col" >
        <input type = "text" placeholder = "Error code (range)" valueLink = {
            this.props.valueLink
          }
          id = "alerterrorcode"  name="alerterrorcode" disabled={this.props.edit} />
      </div>
    </div>
  );
}
});



// http://voidcanvas.com/react-tutorial-two-way-data-binding/
var AlertSite = React.createClass({
  getDefaultProps: function() {
    return {
      multiple: true,
      name: 'selectSite'
    }
  },
  // https://github.com/JedWatson/react-select/issues/256
  onChange(textValue, arrayValue) {
    // Multi select: grab values and send array of values to valueLink
    this.props.updateValue(_.pluck(arrayValue, 'value').join());
  },
  render: function() {
    var siteOptions = [];
    siteOption = {};
    siteOption["value"] = "";
    siteOption["label"] = "All"
    siteOptions.push(siteOption);

    for (var i = 0; i < this.props.sites.length; i++) {
      siteOption = {};
      siteOption["value"] = this.props.sites[i].id;
      siteOption["label"] = this.props.sites[i].name;
      siteOptions.push(siteOption);
    }

    var {
      value,
      onChange
    } = this.props;
    return (
      < div className = "row">
      <div className = "col pe-2">
        <label className="tooltip">Sites
          <div className="tooltiptext_r">Sites using this Alert.</div>
        </label>
      </div>
      <div className = "col">
        <Select
          name = "site"
          value = {
            value
          }
          options = {
            siteOptions
          }
          multi = {
            true
          }
          placeholder = "All"
          onChange = {
            this.onChange
          }
          disabled = {
            this.props.disable_all_selects
          }
          />
      </div>
    </div>
  );
}
});


var AlertDevice = React.createClass({
  getDefaultProps: function(){
    return {
      multiple: true,
      name: 'selectDevice'
    }
  },
  onChange(textValue, arrayValue) {
    // Multi select: grab values and send array of values to valueLink
    this.props.valueLink.requestChange(_.pluck(arrayValue, 'value').join());
  },
  render: function() {
    var deviceOptions = [];

    deviceOption = {};
    deviceOption["value"] = "";
    deviceOption["label"] = "All"
    deviceOptions.push(deviceOption);

    for (var i = 0; i < this.props.devices.length; i++) {
      deviceOption = {};
      deviceOption["value"] = this.props.devices[i].id;
      deviceOption["label"] = this.props.devices[i].name;
      deviceOptions.push(deviceOption);
    }

    var {
      valueLink,
      value,
      onChange
    } = this.props;
    return (
      <div className = "row" >
        <div className = "col pe-2" >
          <label className="tooltip">Devices
          <div className="tooltiptext_r">Which Device provides this Alert.</div>
        </label>
        </div>
        <div className = "col" >
          <Select
            name = "device"
            value = {
              value || valueLink.value
            }
            options = {
              deviceOptions
            }
            multi = {
              true
            }
            placeholder = "All"
            onChange = {
              this.onChange
            }
            disabled = {
              this.props.disable_all_selects
            }
            />
        </div>
      </div>
    );
  }
});


//voidcanvas.com/react-tutorial-two-way-data-binding/
var AlertAnomalieType = React.createClass({
  getDefaultProps: function() {
    return {
      multiple: false,
      name: 'Anomalie'
    }
  },
  //https://github.com/JedWatson/react-select/issues/256
  onChange(textValue, arrayValue) {
    this.props.valueLink.requestChange(arrayValue[0].label);
  },
  render: function() {
    var options = [];

    for (var i = 0; i < Object.keys(this.props.anomalie_types).length; i++) {
      option = {};
      option["value"] = i;
      option["label"] = Object.keys(this.props.anomalie_types)[i];
      options.push(option);
    }

    var {
      valueLink,
      value,
      onChange
    } = this.props;
    return (
      < div className = "row" id = "anomalieRow">
      <div className = "col pe-2" >
        <label className="tooltip">Anomalie Type
          <div className="tooltiptext_r">Anomalie Type Tooltip</div>
        </label>
      </div>
      <div className = "col">
        <Select
          name = "anomalie"
          value = {
            value || valueLink.value
          }
          options = {
            options
          }
          multi = {
            false
          }
          onChange = {
            this.onChange
          }
          disabled = {
            this.props.disable_all_selects
          }
          placeholder="Select"
          clearable = { false }
          />
      </div>
    </div>
  );
}
});



var AlertChannel = React.createClass({
  getDefaultProps: function(){
    return {
      multiple: false,
      name: 'Channel'
    }
  },
  //github.com/JedWatson/react-select/issues/256
  onChange(textValue, arrayValue) {
    this.props.valueLink.requestChange(arrayValue[0].label);
  },
  render: function() {
    var options = [];
    for (var i = 0; i < Object.keys(this.props.channel_types).length; i++) {
      option = {};
      option["value"] = i;
      option["label"] = Object.keys(this.props.channel_types)[i];
      options.push(option);
    }

    var {
      valueLink,
      value,
      onChange
    } = this.props;
    return (
      < div className = "row" id = "channelrow" >
      <div className = "col pe-2" >
        <label className="tooltip">Channel
          <div className="tooltiptext_r">How the Alert is delivered</div>
        </label>
      </div>
      <div className = "col" >
        <Select
          name = "channel"
          value = {
            value || valueLink.value
          }
          options = {
            options
          }
          multi = {
            false
          }
          onChange = {
            this.onChange
          }
          disabled = {
            this.props.disable_all_selects
          }
          clearable = { false }
          />
      </div>
    </div>
  );
}
});



var AlertRole = React.createClass({
  getDefaultProps: function() {
    return {
      multiple: true,
      name: 'selectRole',
    }
  },
  onChange(textValue, arrayValue) {
    // Multi select: grab values and send array of values to valueLink
    this.props.valueLink.requestChange(_.pluck(arrayValue, 'value').join());
  },
  render: function() {
    var roleOptions = [];

    roleOption = {};
    roleOption["value"] = "";
    roleOption["label"] = "None"
    roleOptions.push(roleOption);

    for (var i = 0; i < this.props.roles.length; i++) {
      roleOption = {};
      roleOption["value"] = this.props.roles[i].id;
      roleOption["label"] = this.props.roles[i].name;
      roleOptions.push(roleOption);
    }

    var {
      valueLink,
      value,
      onChange
    } = this.props;
    return (
      < div className = "row" >
      <div className = "col pe-2" >
        <label className="tooltip">Roles
          <div className="tooltiptext_r">Roles this Alert applies to</div>
        </label>
      </div>
      <div className = "col" >
        <Select
          name = "role"
          value = {
            value || valueLink.value
          }
          options = {
            roleOptions
          }
          multi = {
            true
          }
          placeholder = "None"
          onChange = {
            this.onChange
          }
          disabled = {
            this.props.disable_all_selects
          }
          />
      </div>
    </div>
  );
}
});


//voidcanvas.com/react-tutorial-two-way-data-binding/
var AlertUser = React.createClass({
  getDefaultProps: function() {
    return {
      multiple: true,
      name: 'selectuser',
    }
  },
  onChange(textValue, arrayValue) {
    this.props.valueLink.requestChange(_.pluck(arrayValue, 'value').join());
  },
  render: function() {
    var userOptions = [];

    userOption = {};
    userOption["value"] = "";
    userOption["label"] = "None"
    userOptions.push(userOption);

    for (var i = 0; i < this.props.users.length; i++) {
      userOption = {};
      userOption["value"] = this.props.users[i].id;
      userOption["label"] = this.props.users[i].email;
      userOptions.push(userOption);
    }

    var {
      valueLink,
      value,
      onChange
    } = this.props;
    return (
      <div className = "row">
        <div className = "col pe-2">
          <label className="tooltip">Internal Recipient
            <div className="tooltiptext_r">Internal Recipient Tooltip</div>
          </label>
        </div>
        <div className = "col">
          <Select
            name = "user"
            value = {
              value || valueLink.value
            }
            options = {
              userOptions
            }
            multi = {
              true
            }
            placeholder = "None"
            onChange = {
              this.onChange
            }
            disabled = {
              this.props.disable_all_selects
            }
            />
        </div>
      </div>
    );
  }
});


/* taken out for now, not used
var AlertPatient = React.createClass({
render: function() {
return (
<div className="row">
<div className="col pe-2">
<label>All Patients</label >
</div>
<div className="col">
<input
type="checkbox"
checkedLink={this.props.checkedLink}
id="alertpatient"
/>
<label>
&nbsp;
</label>
</div >
</div>
);
}
});
*/


var AlertSampleId = React.createClass({
  render: function() {
    return (
      < div className = "row" id = "sampleidrow" >
      <div className = "col pe-2" >
        <label className="tooltip">Sample Id
          <div className="tooltiptext_r">ID of the Sample that produced this Alert</div>
        </label>
      </div>

      <div className = "col" >
        <input type = "text" placeholder = "Sample ID" valueLink = {
            this.props.valueLink
          }
          id = "alertsampleid" disabled={this.props.edit} />
      </div>
    </div>
  );
}
});



var AlertSmsLimit = React.createClass({
  render: function() {
    return (
      < div className = "row" id = "smslimitrow" >
      <div className = "col pe-2" >
        <label className="tooltip">Daily SMS Limit
          <div className="tooltiptext_r">Maximum number of SMS messages per day this alert can send</div>
        </label>
      </div>

      <div className = "col" >
        <input type = "text"  type="number" min="0" max="10000" placeholder = "sms limit" valueLink = {
            this.props.valueLink
          }
          id = "alertsmslimit" disabled={this.props.edit} />
      </div>
    </div>
  );
}
});


var AlertEmailLimit = React.createClass({
  render: function() {
    return (
      < div className = "row" id = "emaillimitrow" >
      <div className = "col pe-2" >
        <label className="tooltip">Daily Email Limit
          <div className="tooltiptext_r">Maximum number of Email messages per day this alert can send</div>
        </label>
      </div>

      <div className = "col" >
        <input type = "text"  type="number" min="0" max="10000" placeholder = "email limit" valueLink = {
            this.props.valueLink
          }
          id = "alertemaillimit" disabled={this.props.edit} />
      </div>
    </div>
  );
}
});


var AlertEmailMessage = React.createClass({
  render: function() {
    return (
      <div className = "row" id = "messagerow">
        <div className = "col pe-2">
          <label className="tooltip">Email Message
            <div className="tooltiptext_r">Email Content used when sending Alert</div>
          </label>
        </div>

        <div className = "col" >
          <textarea rows="4" cols="35" placeholder = "Email message" valueLink = {
              this.props.valueLink
            }
            id = "alertmessage" pattern=".{5,1024}" disabled={this.props.edit} />
        </div>
      </div>
    );
  }
});


var AlertSmsMessage = React.createClass({
  render: function() {
    return (
      <div className = "row" id = "smsmessagerow" >
        <div className = "col pe-2" >
          <label className="tooltip">SMS Message
            <div className="tooltiptext_r">SMS Content used when sending Alert</div>
          </label>
        </div>

        <div className = "col" >
          <textarea rows="4" cols="35" placeholder = "SMS message" valueLink = {
              this.props.valueLink
            }
            id = "alertsmsmessage" pattern=".{5,160}" disabled={this.props.edit} />
        </div>
      </div>
    );
  }
});
