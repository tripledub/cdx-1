class TestBatchList extends React.Component{
  render() {
    return(
      <div className="row">
        <DisplayFieldWithLabel fieldLabel={I18n.t("components.test_batch.status_label")} fieldValue={ this.props.testBatch.status } />
      </div>
    );
  }
}

TestBatchList.propTypes = {
  testBatch: React.PropTypes.object,
};
