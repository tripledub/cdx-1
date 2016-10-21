class EncounterExaminationReason extends React.Component {
  render(){
    return(
      <RowContainer>
        <EncounterFormColumn classNames="flexStart">
          <FormLabel title={ I18n.t("components.fresh_tests_encounter_form.reason_for_examination_label") } />
        </EncounterFormColumn>
        <EncounterFormColumn classNames="flexStart">
          <FormRadioButton onChange={ this.props.reasonClicked } checked={ this.props.encounter.exam_reason === 'diag' } name="diag_reason" id="exam_reason_diag" value="diag" />
          <FormLabel htmlFor="exam_reason_diag" title={ I18n.t("components.fresh_tests_encounter_form.diagnosis_lable") } />
          <FormRadioButton onChange={ this.props.reasonClicked } checked={ this.props.encounter.exam_reason === 'follow' } name="follow_reason" id="exam_reason_follow" value="follow" />
          <FormLabel htmlFor="exam_reason_follow" title={ I18n.t("components.fresh_tests_encounter_form.follow_up_lable") } />
        </EncounterFormColumn>
      </RowContainer>
    );
  }
}

EncounterExaminationReason.propTypes = {
  reasonClicked: React.PropTypes.func.isRequired,
  encounter: React.PropTypes.object.isRequired,
};
