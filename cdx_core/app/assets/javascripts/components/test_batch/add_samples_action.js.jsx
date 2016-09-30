class AddSamplesAction extends React.Component{
  constructor(props, context) {
    super(props, context);
  }

  submitSamples(event) {
    this.refs.addSamplesModal.show();
    event.preventDefault();
  }

  closeAndCancel() {
    this.refs.addSamplesModal.hide();
  }

  render() {
    return(
      <div className="col-6">
        <button className="btn-secondary" onClick={ this.submitSamples.bind(this) }>{ I18n.t('components.add_samples_action.submit_samples') }</button>
        <Modal ref="addSamplesModal">
          <h1>{ I18n.t('components.add_samples_action.sample_ids') }: { this.props.batchId }</h1>
          <form method="post" action={ this.props.submitSamplesUrl }>
            <input type='hidden' name='authenticity_token' value={this.props.authenticityToken} />
            <div className="col">
              { this.props.patientResults.map(function(patientResult, element) {
                 return <SampleRow key={ patientResult.id } elementId={ 'input' + element } resultId={ patientResult.id } resultName={ patientResult.testType } resultSampleId={ patientResult.sampleId } />;
              }.bind(this)) }
            </div>
            <div className="col">
              <button className="btn-link" type="reset" onClick={ this.closeAndCancel.bind(this) }>{ I18n.t('components.cancel') }</button>
              <button className="btn-primary save" type="submit" >{ I18n.t('components.add_samples_action.save_sample_ids') }</button>
            </div>
          </form>
        </Modal>
      </div>
    );
  }
}

AddSamplesAction.propTypes = {
  batchId: React.PropTypes.string.isRequired,
  patientResults: React.PropTypes.array.isRequired,
  submitSamplesUrl: React.PropTypes.string.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
};
