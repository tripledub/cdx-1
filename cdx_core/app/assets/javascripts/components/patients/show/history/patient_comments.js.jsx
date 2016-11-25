var PatientComments = React.createClass({
  getInitialState: function() {
    return {
      patientComments: [],
      orderBy: this.props.defaultCommentsOrder,
      pagination: {},
      pageNumber: 1,
      loadingMessage: I18n.t("components.patients.show.history.msg_loading_comment"),
      availableColumns: [
        { title: I18n.t("components.patients.show.history.col_comment_date"),fieldName: 'comments.created_at' },
        { title: I18n.t("components.patients.show.history.col_commenter"),   fieldName: 'users.first_name' },
        { title: I18n.t("components.patients.show.history.col_comment_des"), fieldName: 'comments.description' }
      ]
    };
  },

  getData: function(field, pageNumber, event) {
    if (event) { event.preventDefault(); }
    this.serverRequest = $.get(this.props.commentsUrl + this.getParams(field, pageNumber), function (results) {
      if (results['rows'].length > 0) {
        this.setState({ pagination: results['pages'] });
        this.setState({ patientComments: results['rows'] });
        this.setState({ orderBy: results['order_by'] });
        $("table").resizableColumns({store: window.store});
      } else {
        this.setState({ loadingMessage: I18n.t("components.patients.show.history.msg_no_comment") });
      };
    }.bind(this));
  },

  pageData: function(pageNumber){
    this.getData(this.state.orderBy, pageNumber)
  },

  getParams: function(field, pageNumber) {
    if (!field) {
      return '';
    };

    if(!pageNumber) {
      pageNumber = this.state.pageNumber;
    }

    this.setState({ pageNumber: pageNumber });
    return '&order_by='+ field + '&page=' + pageNumber;
  },

  componentDidMount: function() {
    this.getData(this.state.orderBy);
  },

  componentWillUnmount: function() {
    this.serverRequest.abort();
  },

  render: function(){
    var rows       = [];
    var rowHeaders = [];
    var that       = this;

    this.state.patientComments.forEach(
      function(comment) {
        rows.push(<PatientComment comment={comment} key={comment.id} />);
      }
    );

    this.state.availableColumns.forEach(
      function(availableColumn) {
        rowHeaders.push(
          <OrderedColumnHeader key={ availableColumn.fieldName } title={ availableColumn.title } fieldName={ availableColumn.fieldName } orderEvent={ that.getData } orderBy={ that.state.orderBy } />
        );
      }
    );

    return (
      <div className="row">
        {
          this.state.patientComments.length < 1 ? <LoadingResults loadingMessage={this.state.loadingMessage} /> :
          <table className="table patient-history" data-resizable-columns-id="patient-comments-table">
            <thead>
              <tr>
                {rowHeaders}
              </tr>
            </thead>
            <tfoot>
              <tr>
                <td>
                  <Paginator pages={ this.state.pagination } pageData={ this.pageData }/>
                </td>
              </tr>
            </tfoot>
            <tbody>
              {rows}
            </tbody>
          </table>
        }
      </div>
    );
  }
});
