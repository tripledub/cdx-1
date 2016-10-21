class EncounterSampleType extends React.Component{
  constructor(props) {
    super(props);
    let showCommentBox = (props.selectValue === 'other');
    this.state = { showCommentBox: showCommentBox };
  }

  onChange(fieldName, event){
    if (event.target.name === 'coll_sample_type') {
      this.setState({ showCommentBox: (event.target.value === 'other') });
    }

    this.props.onChange(fieldName, event.target.value);
  }

  render(){
    return(
      <div>
        <SampleSelect onChange={ this.onChange.bind(this) } options={ this.props.options } defaultValue={ this.props.selectValue } />
        { this.state.showCommentBox === true ? <SampleOtherComment onChange={ this.onChange.bind(this) } defaultValue={ this.props.commentValue || '' } /> : null }
      </div>
    );
  }
};

EncounterSampleType.propTypes = {
  onChange: React.PropTypes.func.isRequired,
  options: React.PropTypes.array.isRequired,
  selectValue: React.PropTypes.string,
  commentValue: React.PropTypes.string,
};
