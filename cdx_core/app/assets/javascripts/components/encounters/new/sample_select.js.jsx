class SampleSelect extends React.Component {
  onChange(event) {
    this.props.onChange('coll_sample_type', event);
  }

  render(){
    let options = this.props.options.map(function(option, index){
      return <option key={ index } value={ option }>{ I18n.t('components.fresh_tests_encounter_form.' + option + '_option') }</option>
    });
    return(
      <RowContainer>
        <EncounterFormColumn>
          <FormLabel htmlFor="colSampleType" title={ I18n.t("components.fresh_tests_encounter_form.collection_sample_type_label") } />
        </EncounterFormColumn>
        <EncounterFormColumn>
          <select className="input-large" id="colSampleType" name="coll_sample_type" onChange={ this.onChange.bind(this) } defaultValue={ this.props.selectValue }>
            { options }
          </select>
        </EncounterFormColumn>
      </RowContainer>

    );
  }
}

SampleSelect.propTypes = {
  onChange: React.PropTypes.func.isRequired,
  options: React.PropTypes.array.isRequired,
  selectValue: React.PropTypes.string,
};
