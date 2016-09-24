var StatusActions = Reflux.createActions(['updateStatus']);

var TestBatchStore = Reflux.createStore({
  listenables: StatusActions,

  init: function() {
    this.state = {count:0};
  },

  onUpdateStatus: function(newStatus) {
    console.log('status updated ' + newStatus);
    this.trigger(newStatus);
  }
});
