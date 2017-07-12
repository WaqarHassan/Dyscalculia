$(function() {
  // http://stackoverflow.com/questions/9389789/javascript-older-than-18-on-leap-years
  function meetsMinimumAge(birthDate, minAge) {
      var tempDate = new Date(birthDate.getFullYear() + minAge, birthDate.getMonth(), birthDate.getDate());
      console.log(tempDate);
      return (tempDate <= new Date());
  }

  $('#show-when-old').hide();

  $('.user_date_of_birth').change(function() {
    var day = $('#user_date_of_birth_3i').val()-1;
    var month = $('#user_date_of_birth_2i').val()-1;
    var year = $('#user_date_of_birth_1i').val();

    if (meetsMinimumAge(new Date(year, month, day), 18)) {
        $('#show-when-old').show();
    } else {
        $('#show-when-old').hide();
    }
  });

  $('.user_date_of_birth').trigger('change');

});
