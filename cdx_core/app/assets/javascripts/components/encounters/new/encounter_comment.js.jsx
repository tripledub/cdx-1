class EncounterComment extends React.Component {
  updateComment(event) {
    this.props.diagCommentChange('diag_comment', event.target.value);
  }

  render() {
    return (
      <RowContainer>
        <EncounterFormColumn classNames="flexStart">
          <FormLabel title={ I18n.t('components.encounters.btn_comment') } htmlFor="diagComment"/>
        </EncounterFormColumn>
        <EncounterFormColumn>
          <FormTextArea name="diag_comment" maxLength="200" id="diagComment" defaultValue={ this.props.defaultValue } rows="5" cols="60" onChange={ this.updateComment.bind(this) } />
        </EncounterFormColumn>
      </RowContainer>
    );
  }
};
