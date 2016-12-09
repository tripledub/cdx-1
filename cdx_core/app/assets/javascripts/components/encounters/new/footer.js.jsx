class EncounterFooter extends React.Component {
  constructor(props) {
    super(props);
    this.state = { btnDisabled: false };
  }

  validateThenSave(event) {
    event.preventDefault();
    this.setState({ btnDisabled: true });
    if (this.props.validateThenSave() === false) {
      this.setState({ btnDisabled: false });
    };
  }

  render(){
    return(
      <RowContainer classNames="labelfooter">
        <div className="col-12">
          <ul>
            <li>
              <button className="btn-primary save" disabled={ this.state.btnDisabled } onClick={ this.validateThenSave.bind(this) }>{ I18n.t("components.fresh_tests_encounter_form.save_btn") }</button>
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
