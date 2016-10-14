class PrintSampleIdButton extends React.Component{

  printBarcode() {
    window.print();
  }

  render() {
    return(
      <div>
        <a className="btn-primary" href="#" onClick={ this.printBarcode.bind(this) } title={ I18n.t("components.test_order.print_label_title") }>
          { I18n.t("components.test_order.print_label") }
        </a>
      </div>
    )
  }
}

PrintSampleIdButton.propTypes = {
};
