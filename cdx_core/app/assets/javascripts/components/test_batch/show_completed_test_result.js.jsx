class ShowCompletedTestResult extends React.Component {
  render() {
    return(
      <div>
        <strong>{ I18n.t('components.test_result_status.test_completed') }</strong> -
        <a className="btn" href={ this.props.showResultUrl }>{ I18n.t('components.test_result_status.show_test_result') }</a>
      </div>
    )
  }
}

ShowCompletedTestResult.propTypes = {
  showResultUrl: React.PropTypes.string.isRequired,
};
