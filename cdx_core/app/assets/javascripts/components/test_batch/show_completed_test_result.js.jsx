class ShowCompletedTestResult extends React.Component {
  render() {
    return(
      <p>
        <strong>{ I18n.t('components.test_result_status.test_completed') }</strong> -
        <a href={ this.props.showResultUrl }>{ I18n.t('components.test_result_status.show_test_result') }</a>
      </p>
    )
  }
}

ShowCompletedTestResult.propTypes = {
  showResultUrl: React.PropTypes.string.isRequired,
};
