class EncounterFooter extends React.Component {
  validateThenSave(event) {
    event.preventDefault();
    this.props.validateThenSave();
  }
  render(){
    return(
      <RowContainer classNames="labelfooter">
        <div className="col-12">
          <ul>
            <li>
              <a href="#" id="encountersave" className="button save" onClick={ this.validateThenSave.bind(this) }>{ I18n.t("components.fresh_tests_encounter_form.save_btn") }</a>
            </li>
            <li>
              <a href={ this.props.cancelUrl } className="button cancel">{ I18n.t("components.fresh_tests_encounter_form.cancel_btn") }</a>
            </li>
          </ul>
        </div>
      </RowContainer>
    );
  }
}

EncounterFooter.propTypes = {
  cancelUrl: React.PropTypes.string.isRequired,
  validateThenSave: React.PropTypes.func.isRequired,
};
