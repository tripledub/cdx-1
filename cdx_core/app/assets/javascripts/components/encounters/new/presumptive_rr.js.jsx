class PresumptiveRR extends React.Component {
  onChange(event){
    this.props.updatePresumptiveRR('presumptive_rr', event.target.checked);
  }

  render() {
    return (
      <div className='presumptiveclass'>
      <RowContainer>
        <EncounterFormColumn />
        <EncounterFormColumn>
          <FormCheckBox type="checkbox" checked={ this.props.checked } onChange={ this.onChange.bind(this) } className="presumptive_rr" id="presumptiveRR" name="presumptive_rr" />
          <FormLabel title={ I18n.t("components.fresh_tests_encounter_form.presumptive") } htmlFor="presumptiveRR" />
        </EncounterFormColumn>
      </RowContainer>
      </div>
    )
  }
};

PresumptiveRR.propTypes = {
  checked: React.PropTypes.bool.isRequired,
};