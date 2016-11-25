class DeviceMessageLink extends React.Component {
  render() {
    if (this.props.testOrderLink) {
      return(<a href={ this.props.testOrderLink } title={ I18n.t("components.test_order.header") }>Y</a>);
    } else {
      return(null);
    }
  }
}
