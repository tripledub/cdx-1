var PatientEpisodesContent = React.createClass({
  render: function(){
    return(
      <div className="row episodeSummary">
        <div className="col-12">
          {this.props.currentTab === 1 ?
            <ShowPatientEpisodes episodesUrl={this.props.episodesUrl} filterEpisodes='0' />
            :null}

          {this.props.currentTab === 2 ?
            <ShowPatientEpisodes episodesUrl={this.props.episodesUrl} filterEpisodes='1' />
            :null}
        </div>
      </div>
    );
  }
});
