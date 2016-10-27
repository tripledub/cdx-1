var PatientComments = React.createClass({
  getInitialState: function() {
    return {
      patientComments: [],
      queryOrder: true,
      pagination: {},
      pageNumber: 1,
      activeField: 'date',
      loadingMessasge: I18n.t("components.patients.show.history.msg_loading_comment"),
      orderedColumns: {},
      availableColumns: [
        { title: I18n.t("components.patients.show.history.col_comment_date"),        fieldName: 'date' },
        { title: I18n.t("components.patients.show.history.col_commenter"),   fieldName: 'commenter' },
        { title: I18n.t("components.patients.show.history.col_comment_des"), fieldName: 'description' }
      ]
    };
  },

  getData: function(field, pageNumber, e) {
    if (e) { e.preventDefault(); }
    this.serverRequest = $.get(this.props.commentsUrl + this.getParams(field, pageNumber), function (results) {
      if (results['rows'].length > 0) {
        this.setState({ pagination: results['pages'] });
        this.setState({ patientComments: results['rows'] });
        this.updateOrderIcon(field);
        $("table").resizableColumns({store: window.store});
      } else {
        this.setState({ loadingMessage: I18n.t("components.patients.show.history.msg_no_comment") });
      };
    }.bind(this));
  },

  pageData: function(pageNumber){
    this.getData(this.state.activeField, pageNumber)
  },

  getParams: function(field, pageNumber) {
    var queryOrder = this.state.queryOrder;
    if(!pageNumber) {
      pageNumber = this.state.pageNumber;
      queryOrder = !this.state.queryOrder;
      this.setState({ queryOrder: queryOrder });
    }
    this.setState({ activeField: field });
    this.setState({ pageNumber: pageNumber });
    return '&field='+ field + '&order=' + queryOrder + '&page=' + pageNumber;
  },

  updateOrderIcon: function(orderedField) {
    var that                       = this;
    var updatedState               = {};
    var iconValue                  = (this.state.queryOrder == true) ? '&#x25BC;' : '&#x25B2;';
    this.state.availableColumns.forEach(
      function(column) {
        updatedState[column.fieldName] = ''
      }
    );
    updatedState[orderedField] = iconValue;
    this.setState({ orderedColumns: updatedState });
  },

  componentDidMount: function() {
    this.getData('date');
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
        rowHeaders.push(<OrderedColumnHeader key={availableColumn.fieldName} title={availableColumn.title} fieldName={availableColumn.fieldName} orderEvent={that.getData} orderIcon={that.state.orderedColumns[availableColumn.fieldName]} />);
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
