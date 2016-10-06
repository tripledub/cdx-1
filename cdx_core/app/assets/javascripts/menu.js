$(document).ready( function()
{
  var menu_open = false;

  function close_accounts_menu()
  {
    if( menu_open )
    {
      $('#dropdown-form').parent().removeClass('show-nav-menu');
      menu_open = false;
    }
  }

  $('body').on('click', close_accounts_menu );

  $(".icon-user").on('click', function()
  {
    var $dropdown = $(this).parent();
    if( $dropdown.hasClass('show-nav-menu') )
      close_accounts_menu();
    else
    {
      $dropdown.addClass('show-nav-menu');
      setTimeout(function(){ menu_open = true; }, 1000);
    }
  });

  $('.user .select_lang').on('change', function(){
    var lang = $(this).val();
    $.ajax({
      url: '/users/change_language',
      data: {language: lang},
      success: function(){
        location.reload();
      }
    });
  });
});