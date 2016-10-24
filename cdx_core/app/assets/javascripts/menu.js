// JS for shared/_header_dropdown.html.haml
$(document).ready(function() {
  $('body').append('<div class=\'menu-overlay\'></div>');

  var $menuOverlay  = $('.menu-overlay');
  var $userDropdown = $('.user .user-dropdown');

  $menuOverlay.on('click', function() {
    $userDropdown.removeClass('active');
    $menuOverlay.removeClass('active');
  });

  $('.user-dropdown-link').on('click', function(e) {
    e.stopPropagation(); e.preventDefault();

    if($userDropdown.hasClass('active')) {
      $userDropdown.removeClass('active');
      $menuOverlay.removeClass('active');
    } else {
      $userDropdown.addClass('active');
      $menuOverlay.addClass('active');
    }
  });

  $('.user .select_lang').on('change', function(){
    var lang = $(this).val();
    $.ajax({
      url: '/users/change_language',
      data: { language: lang },
      success: function(){
        location.reload();
      }
    });
  });
});
