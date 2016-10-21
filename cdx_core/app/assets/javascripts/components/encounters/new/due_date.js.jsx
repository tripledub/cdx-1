class EncounterDueDate extends React.Component {
  constructor(props) {
    super(props);
    let now = new Date();
    let day = ("0" + now.getDate()).slice(-2);
    let month = ("0" + (now.getMonth() + 1)).slice(-2);
    this.state = { currentDate: now.getFullYear() + "-" + (month) + "-" + (day) };
  }
  onChange(event){
    this.props.onChange('testdue_date', event.target.value);
  }

  render() {
    return (
      <RowContainer>
        <EncounterFormColumn>
          <FormLabel title={ I18n.t("components.fresh_tests_encounter_form.presumptive") } htmlFor="testdueDate" />
        </EncounterFormColumn>
        <EncounterFormColumn>
          <FormInputDate onChange={ this.onChange.bind(this) } id="testdueDate" name="testdue_date" minValue={ this.state.currentDate } defaultValue={ this.props.defaultValue }/>
        </EncounterFormColumn>
      </RowContainer>
    )
  }
};

EncounterDueDate.propTypes = {
  defaultValue: React.PropTypes.string.isRequired,
  onChange: React.PropTypes.func.isRequired,
};
