class TestBatchRow extends React.Component{
  constructor(props, context) {
    super(props, context);

    this.state = {
      patientResultStatus: this.props.patientResult.status,
      commentValue: this.props.patientResult.comment,
    }
  }

  updateResultStatus(status, comment) {
    this.setState({ patientResultStatus: status, commentValue: comment })
  }

  render() {
    return(
      <tr>
        <td>{ this.props.patientResult.testType }</td>
        <td>{ this.props.patientResult.sampleId }</td>
        <td>{ this.props.patientResult.examinedBy }</td>
        <td>{ I18n.t('components.patient_results.' + this.state.patientResultStatus) }</td>
        <td><TestResultStatus feedbackMessage={ this.props.patientResult.feedbackMessage } resultId={ this.props.patientResult.id } rejectReasons={ this.props.rejectReasons } editResultUrl={ this.props.patientResult.editUrl } showResultUrl={ this.props.patientResult.showResultUrl } commentValue={ this.state.commentValue } updateResultStatus={ this.updateResultStatus.bind(this) } currentStatus={ this.state.patientResultStatus } encounterRoutes={ this.props.encounterRoutes } /></td>
      </tr>
    )
  }
}

TestBatchRow.propTypes = {
  patientResult: React.PropTypes.object.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  encounterRoutes: React.PropTypes.object.isRequired,
};
