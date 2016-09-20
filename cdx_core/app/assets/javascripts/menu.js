$(document).on("ready", function(){
  $(".icon-user").on('click', function(){
    $(".user").toggleClass("show-nav-menu");
  });
  
  $('body').click(function(e){
    if (!e.target.matches('.icon-user')){
      if($('.user').hasClass('show-nav-menu')){
        $('.user').removeClass('show-nav-menu');
      }
    }
  });
  
  $('.select_lang').on('change', function(){
    var lang = $('.select_lang').val();
    $.ajax({
      url: '/users/change_language',
      data: {language: lang},
      success: function(){
        location.reload();
      }
    });
  });
});