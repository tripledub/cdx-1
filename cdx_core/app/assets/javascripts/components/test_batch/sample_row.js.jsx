class SampleRow extends React.Component{
  render(){
    return(
      <div className="row">
        <div className="col-6">
          <label>{ I18n.t('components.add_samples_action.enter_sample_id') }</label>
        </div>
        <div className="col-6">
          <input type="text" required ref={ 'sampleInput' + this.props.elementId } name={ 'samples['+this.props.elementId+']' } />
        </div>
      </div>
    )
  }
}

SampleRow.propTypes = {
  resultId: React.PropTypes.number,
};
