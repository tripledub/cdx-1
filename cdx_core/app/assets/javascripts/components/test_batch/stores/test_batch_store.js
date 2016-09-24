var StatusActions = Reflux.createActions(['updateStatus']);

var TestBatchStore = Reflux.createStore({
  listenables: StatusActions,

  init: function() {
    this.state = {count:0};
  },

  onUpdateStatus: function(newStatus) {
    this.trigger(newStatus);
  }
});
