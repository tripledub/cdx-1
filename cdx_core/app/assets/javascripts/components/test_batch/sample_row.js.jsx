class SampleRow extends React.Component{
  automaticSampleId() {
    let batchNumber = this.props.batchId.substr(this.props.batchId.length - 5);;
    return parseInt(batchNumber) * 1000 + (this.props.elementId + 1);
  }

  componentDidMount() {
    let inputName = 'sampleInput' + this.props.elementId;
    $( "." + inputName ).focus();
  }

  render(){
    return(
      <div className="row">
        <div className="col-6">
          <label>{ I18n.t('components.add_samples_action.enter_sample_id') }</label>
        </div>
        <div className="col-6">
          { this.props.manualSampleId ?
            <input type="text" className={ 'sampleInput' + this.props.elementId } name={ 'samples['+this.props.elementId+']' } /> :
            <input type="text" readOnly  name={ 'samples['+this.props.elementId+']' } value={ this.automaticSampleId() }/> }
        </div>
      </div>
    )
  }
}

SampleRow.propTypes = {
  elementId: React.PropTypes.number,
  manualSampleId: React.PropTypes.bool.isRequired,
  batchId: React.PropTypes.string.isRequired,
};
