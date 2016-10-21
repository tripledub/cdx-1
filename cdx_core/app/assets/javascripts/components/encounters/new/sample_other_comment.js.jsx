class SampleOtherComment extends React.Component {
  onChange(event) {
    this.props.onChange('coll_sample_other', event);
  }

  render(){
    return(
      <RowContainer>
        <EncounterFormColumn>
          <FormLabel htmlFor="sampleOther" title={ I18n.t("components.fresh_tests_encounter_form.sample_type") } />
        </EncounterFormColumn>
        <EncounterFormColumn>
          <input type="text" name="sample_other" id="sampleOther" value={ this.props.commentValue } onChange={ this.onChange.bind(this) } />
        </EncounterFormColumn>
      </RowContainer>
    );
  }
}

SampleOtherComment.propTypes = {
  onChange: React.PropTypes.func.isRequired,
  commentValue: React.PropTypes.string,
};
