class EncounterTestingFor extends React.Component {
  render(){
    return(
      <RowContainer>
        <EncounterFormColumn>
          <FormLabel title={ I18n.t("components.fresh_tests_encounter_form.testing_for_label") } />
        </EncounterFormColumn>
        <EncounterFormColumn>
          <FormLabel title={ I18n.t("components.fresh_tests_encounter_form.TB_option") } />
          <input type="hidden" className="input-large" id="testing_for" name="testing_for" datavalue="TB" />
        </EncounterFormColumn>
      </RowContainer>
    );
  }
}
