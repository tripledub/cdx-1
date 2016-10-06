class AddSamplesAction extends React.Component{
  constructor(props, context) {
    super(props, context);
    this.state = { sampleResults: ['sample'] }
  }

  submitSamples(event) {
    this.refs.addSamplesModal.show();
    event.preventDefault();
  }

  closeAndCancel() {
    this.refs.addSamplesModal.hide();
  }

  addSampleInput() {
    let newResults = this.state.sampleResults;
    newResults.push('sample');
    this.setState({ sampleResults: newResults });
  }

  render() {
    return(
      <div className="col-6">
        <button className="btn-secondary" onClick={ this.submitSamples.bind(this) }>{ I18n.t('components.add_samples_action.submit_samples') }</button>
        <Modal ref="addSamplesModal">
          <h1>{ I18n.t('components.add_samples_action.sample_ids') }: { this.props.batchId }</h1>
          <form method="post" action={ this.props.encounterRoutes['submitSamplesUrl'] }>
            <input type='hidden' name='authenticity_token' value={this.props.authenticityToken} />
            <div className="col">
              { this.state.sampleResults.map(function(sampleResult, element) {
                 return <SampleRow key={ element } elementId={ element } />;
              }.bind(this)) }
            </div>
            <div className="row">
              <div className="col-6"></div>
              <div className="col-6">
                <a className="btn-primary" href="#" onClick={ this.addSampleInput.bind(this) }>Add another sample</a>
              </div>
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
  encounterRoutes: React.PropTypes.object.isRequired,
  authenticityToken: React.PropTypes.string.isRequired,
};
