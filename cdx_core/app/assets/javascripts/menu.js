var menu_open = false;

function close_accounts_menu()
{
  if( menu_open )
  {
    $('#dropdown-form').parent().removeClass('show-nav-menu');
    $('#account_menu_back').remove();
    menu_open = false;
  }
}

$(document).ready( function()
{
  $(".icon-user").on('click', function()
  {
    var $dropdown = $(this).parent();
    if( $dropdown.hasClass('show-nav-menu') )
      close_accounts_menu();
    else
    {
      $dropdown.before('<div id="account_menu_back" onclick="close_accounts_menu()">' );
      $dropdown.addClass('show-nav-menu');
      menu_open = true;
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