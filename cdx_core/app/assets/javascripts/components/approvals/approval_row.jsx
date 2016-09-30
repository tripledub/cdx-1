var ApprovalRow = React.createClass({
  selectedTestOrders: function (selectAll) {
    this.props.selectedTestOrders(selectAll);
  },

  visitLink: function () {
    window.location = this.props.testOrder.viewLink;
  },

  render: function() {
    return (
    <tr>
      <CsvCheckboxColumn columnId={this.props.testOrder.id} selectedTestOrders={this.selectedTestOrders} />
      <td title={this.props.testOrder.batchId} onClick={this.visitLink}>{this.props.testOrder.batchId}</td>
      <td title={this.props.testOrder.status} onClick={this.visitLink}>{this.props.testOrder.status}</td>
      <td title={this.props.testOrder.requestedSiteName} onClick={this.visitLink}>{this.props.testOrder.requestedSiteName}</td>
      <td title={this.props.testOrder.performingSiteName} onClick={this.visitLink}>{this.props.testOrder.performingSiteName}</td>
      <td title={this.props.testOrder.testingFor} onClick={this.visitLink}>{this.props.testOrder.testingFor}</td>
      <td title={this.props.testOrder.requestedBy} onClick={this.visitLink}>{this.props.testOrder.requestedBy}</td>
      <td title={this.props.testOrder.requestDate} onClick={this.visitLink}>{this.props.testOrder.requestDate}</td>
      <td title={this.props.testOrder.testsRequiringApproval} onClick={this.visitLink}>{this.props.testOrder.testsRequiringApproval}</td>
    </tr>);
  }
});
