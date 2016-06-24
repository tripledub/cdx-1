var EpisodeSelectOptionWrapper = React.createClass({
  render: function() {
    return <option>{this.props.data.name}</option>
  }
});

var EpisodeSelectOutcome = React.createClass({
  getInitialState: function() {
    return { selectValue: '' };
  },

  render: function(){
    return(
      <div className="row">
        <div className="col-6">
          <label htmlFor="outcome">Treatment Outcome</label>
        </div>
        <div className="col-6">
          <select name="outcome">
            {this.props.outcomeOptions.map(function(result){
              return <EpisodeSelectOptionWrapper key={result.id} data={result} />
            })}
          </select>
        </div>
      </div>
    );
  }
});
