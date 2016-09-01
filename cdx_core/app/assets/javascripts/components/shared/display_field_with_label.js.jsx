var DisplayFieldWithLabel = React.createClass({
  render: function() {
    return (
      <div className="row">
        <div className="col pe-2">
          <label>{this.props.fieldLabel}</label>
        </div>
        <div className="col">
          <p>{this.props.fieldValue}</p>
        </div>
      </div>
    )
  }
});
