class TestBatchRow extends React.Component{
  constructor(props, context) {
    super(props, context);

    this.state = {
      patientResultStatus: this.props.patientResult.status,
    }
  }

  updateResultStatus(status) {
    this.setState({ patientResultStatus: status })
  }

  render() {
    return(
      <tr>
        <td>{ this.props.patientResult.testType }</td>
        <td>{ this.props.patientResult.sampleId }</td>
        <td>{ this.props.patientResult.examinedBy }</td>
        <td>{ I18n.t('components.patient_results.' + this.state.patientResultStatus) }</td>
        <td><TestResultStatus feedbackMessage={ this.props.patientResult.feedbackMessage } userCanApprove={ this.props.userCanApprove } resultId={ this.props.patientResult.id } rejectReasons={ this.props.rejectReasons } editResultUrl={ this.props.patientResult.editUrl } showResultUrl={ this.props.patientResult.showResultUrl } commentValue={ this.props.patientResult.comment } updateResultStatus={ this.updateResultStatus.bind(this) } currentStatus={ this.props.patientResult.status } encounterRoutes={ this.props.encounterRoutes } /></td>
      </tr>
    )
  }
}

TestBatchRow.propTypes = {
  patientResult: React.PropTypes.object.isRequired,
  userCanApprove: React.PropTypes.bool.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  encounterRoutes: React.PropTypes.object.isRequired,
};
