class ReasonFollow extends React.Component {
  updateWeeks(event) {
    this.props.treatmentDateChange('treatment_weeks', event.target.value);
  }

  render() {
    return (
      <RowContainer>
        <EncounterFormColumn classNames="flexStart">
          <FormLabel htmlFor="treatmentWeeks" title={ I18n.t("components.fresh_tests_encounter_form.weeks_in_treatment_label") } />
        </EncounterFormColumn>
        <EncounterFormColumn>
          <FormInputNumber type="number" minValue="0" maxValue="52" onChange={ this.updateWeeks.bind(this) } defaultValue={ this.props.defaultValue } id="treatmentWeeks" name="treatment_weeks" />
        </EncounterFormColumn>
      </RowContainer>
    );
  }
};

ReasonFollow.propTypes = {
  defaultValue: React.PropTypes.number.isRequired,
};
