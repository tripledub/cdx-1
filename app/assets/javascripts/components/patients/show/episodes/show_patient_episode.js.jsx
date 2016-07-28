var ShowPatientEpisode = React.createClass({
  render: function () {
    return(
      <div className="row">
        <div className="col-12">
          <ul>
            <li>
              <label>
                Diagnosis
              </label>
              {this.props.episode.diagnosis}
            </li>
            <li>
              <label>
                HIV Status
              </label>
              {this.props.episode.hivStatus}
            </li>
            <li>
              <label>
                History
              </label>
              {this.props.episode.initialHistory}
            </li>
          </ul>
          <ul>
            <li>
              <label>
                Drug resistance
              </label>
              {this.props.episode.drugResistance}
            </li>
            <li>
              <label>
                Outcome
              </label>
              {this.props.episode.outcome}
            </li>
            <li>
              <label>
                Diagnosis classify by Anatomical site
              </label>
              &nbsp;{this.props.episode.anatomicalSiteDiagnosis}
            </li>
          </ul>
          <ul>
            <li>
              <a className="button edit" href={this.props.episode.editLink}>Edit episode</a>
            </li>
          </ul>
        </div>
      </div>
    )
  }
})
