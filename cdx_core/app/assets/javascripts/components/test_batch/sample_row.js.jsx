class SampleRow extends React.Component{
  render(){
    return(
      <div className="row">
        <div className="col-6">
          <label>{ this.props.resultName }</label>
        </div>
        <div className="col-6">
          <input type="text" required refs={ this.props.elementId } name={ 'samples['+this.props.resultId+']' } value={ this.props.resultSampleId }/>
        </div>
      </div>
    )
  }
}

SampleRow.propTypes = {
  resultName: React.PropTypes.string,
  resultSampleId: React.PropTypes.string,
  resultId: React.PropTypes.number,
};
