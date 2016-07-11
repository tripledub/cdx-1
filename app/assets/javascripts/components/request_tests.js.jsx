var RequestedTestRow = React.createClass({
  getInitialState: function() {
  return {
    statusField: '',
    test: this.props.requested_test
    };
  },
  statusChanged: function(event) {
    var temp_test = this.state.test;
    temp_test.status=event.target.value;
    this.setState({
      test: temp_test
    });
   this.props.onTestChanged(this.state.test);
  },
  commentChanged: function(new_comment) {
    var temp_test = this.state.test;
    temp_test.comment=new_comment;
    this.setState({
      test: temp_test
    });
   this.props.onTestChanged(this.state.test);
  },
  determineTestResultUrl(id,name, edit, is_associated) {
    var url_path;
    var view_or_cancel_path;
    var test_order_page_mode;
    
    if (edit == true) {
      test_order_page_mode = 'edit';
    } else {
      test_order_page_mode = 'cancel';
    }

    if ((is_associated == true) && (edit == true)) {
      view_or_cancel_path = '/edit?test_order_page_mode='+test_order_page_mode;
    } else
    if ((is_associated == true) || (edit == false)) {
      view_or_cancel_path = '?test_order_page_mode='+test_order_page_mode;
    } else {
      view_or_cancel_path = '/new?test_order_page_mode='+test_order_page_mode;
    }

    switch(name) {
      case 'xpertmtb':
        url_path = "/requested_tests/"+id+"/xpert_result"+view_or_cancel_path;
        break;
      case 'microscopy':
        url_path = "/requested_tests/"+id+"/microscopy_result"+view_or_cancel_path;
        break;
      case 'drugsusceptibility':
        url_path = "/requested_tests/"+id+"/dst_lpa_result"+view_or_cancel_path;
        break;
      case 'culture':
        url_path = "/requested_tests/"+id+"/culture_result"+view_or_cancel_path;
        break;
      default:
        url_path=url_path = "/requested_tests/"+id+"/undefined_result";
    }
    return url_path;
},
  render: function() {
    var encounter = this.props.encounter;

    samples ="";
    for (var i = 0, len = encounter.samples.length;i < len; i++) {
      if (i > 0) {
        samples +=",";
      }
      samples += encounter.samples[i].entity_ids[0]
    }

    created_at = new Date(Date.parse(this.state.test.created_at));
    created_at_date=created_at.toISOString().slice(0, 10);

    var status_array=[];
    for (var index in this.props.status_types) { 
      status_array.push(index);
    }

    var status_data = status_array,
        MakeItem = function(X) {
          return <option key={X} value={X}>{X}</option>;
         };

    var test_result_text;
    var test_result_url;
    var test_id=this.state.test.id;
    associated_patient_result = this.props.associated_tests_to_results.filter(function (el) {return el.requested_test_id == test_id;});

    var is_associated;
    if (associated_patient_result.length == 0) {
      is_associated=false;
    } else {
      is_associated=true;
    }

    if (this.state.test.status=='rejected') {
      test_result_url = "#";
      test_result_text = "";
    } else 
    if ((this.props.edit == true) && (is_associated == false) && 
       ((this.state.test.status == 'pending') || (this.state.test.status == 'inprogress')) ) {
      test_result_url = this.determineTestResultUrl(this.state.test.id, this.state.test.name, this.props.edit, is_associated);
      test_result_text = "Add Result";
    } 
    else if ( (is_associated == false) || ((this.props.cancel==true) && (this.state.test.status=='complete')) ) {
      test_result_url = "#";
      test_result_text = "";
    }
    else {
      test_result_url = this.determineTestResultUrl(this.state.test.id, this.state.test.name, this.props.edit,is_associated);
      test_result_text = "View Result";
    }

  return (
    <tr>
      <td>{this.state.test.name}</td>
      <td>{samples}</td>
      <td>{this.props.requested_by}</td>
      <td>{created_at_date}</td>
      <td>{encounter.testdue_date}</td>
      <td><select key={this.state.test.id} onChange = {
            this.statusChanged
           }
          className="input-x-medium"
          defaultValue={this.state.test.status}
          disabled = {
            !this.props.edit
           }>
          {status_data.map(MakeItem)}
          </select></td>
      <td><TextInputModal key={this.state.test.id} comment={this.state.test.comment} commentChanged={this.commentChanged} edit={this.props.edit}/></td>
      <td><a className="btn-add-link" href={test_result_url}>{test_result_text}</a></td>
      </tr>);
  }
});

var RequestedTestsList = React.createClass({
  getDefaultProps: function() {
    return {
      title: "Requested Tests",
      titleClassName: ""
    }
  },
  onTestChanged: function(new_test) {
    this.props.onTestChanged(new_test)
  },
  render: function() {
    return (
      <table className="table" id="test-table" cellPadding="0" cellSpacing="0">
        <colgroup>
          <col width="10%" />
          <col width="10%" />
          <col width="20%" />
          <col width="15%" />
          <col width="10%" />
          <col width="10%" />
          <col width="10%" />
          <col width="10%" />
        </colgroup>
        <thead>
          <tr>
            <th className="tableheader" colSpan="8">
              <span className={this.props.titleClassName}>{this.props.title}</span>
            </th>
          </tr>
          <tr>
            <td>Name</td>
            <td>Sample ID</td>
            <td>Requested By</td>
            <td>Requested Date</td>
            <td>Due Date</td>
            <td>Status</td>
            <td>Comment</td>
            <td>Result</td>
          </tr>
        </thead>
        <tbody>
          {this.props.requested_tests.map(function(requested_test) {
             return <RequestedTestRow key={requested_test.id} requested_test={requested_test} onTestChanged={this.onTestChanged}
              encounter={this.props.encounter} requested_by={this.props.requested_by}  status_types={this.props.status_types} 
              edit={this.props.edit} associated_tests_to_results={this.props.associated_tests_to_results} />;
          }.bind(this))}
        </tbody>
      </table>
    );
  }
});

var RequestedTestsIndexTable = React.createClass({
  onTestChanged: function(new_test) {
    this.props.onTestChanged(new_test)
   },
  render: function() {
    return <RequestedTestsList requested_tests={this.props.requested_tests} encounter={this.props.encounter} onTestChanged={this.onTestChanged}
              title={this.props.title} requested_by={this.props.requested_by} titleClassName="table-title" status_types={this.props.status_types} 
              edit={this.props.edit} associated_tests_to_results={this.props.associated_tests_to_results}/>
  }
});
