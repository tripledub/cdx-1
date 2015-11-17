var AddItemSearchSampleTemplate = React.createClass({
  render: function() {
    return (<span title={this.props.item.uuid}>{this.props.item.entity_ids[0]}</span>);
  }
});

var Sample = React.createClass({

  unifySample: function(event) {
    this.props.onUnifySample(this.props.sample);
    event.preventDefault();
  },


  render: function() {
    var unifiedSamples = null;
    if (this.props.sample.entity_ids.length > 1) {
      unifiedSamples = (
        <div className="unified">
          <span>Unified samples</span>
          <ul>
            {_(this.props.sample.entity_ids).rest().map(function(entity_id) {
              return (<li key={entity_id}>{entity_id}</li>);
            }).value()}
          </ul>
        </div>);
    }

    var unifySampleAction = null;
    if (this.props.onUnifySample) {
      unifySampleAction = (<a href="#" className="unify" onClick={this.unifySample}><span className="icon-unify"></span></a>);
    }

    return (
    <li>
      {unifySampleAction}
      {this.props.sample.entity_ids[0]}
      {unifiedSamples}
    </li>);
  }
});

var SamplesList = React.createClass({
  render: function() {
    var _this = this;
    return (
      <ul className="samples">
        {this.props.samples.map(function(sample) {
           return <Sample key={sample.uuid} sample={sample} onUnifySample={_this.props.onUnifySample}/>;
        })}
      </ul>
    );
  }
});
