var LabelTooltip = React.createClass({
  render: function(){
    return (
      <div className="tooltip">
        <label htmlFor={this.props.labelName}>{this.props.labelValue}</label>
        <div className="tooltiptext_r">
          {this.props.labelTooltip}
        </div>
      </div>
    );
  }
});
