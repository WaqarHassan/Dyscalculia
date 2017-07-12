$(function() {
  var $test_progress_bar = $('.test-progress-bar');
  $test_progress_bar.each(function() {
    var $this = $(this);
    var height = $this.data('progress');
    var $fill_bar = $this.find('.test-progress-bar-fill');
    $fill_bar.animate({
      height: height
    }, 1000);
  });

  $('#completed')[0].checked = localStorage.getItem('show-completed') === 'true';

  $('#completed').on('change', function() {
    var $completed = $('.completed');
    localStorage.setItem('show-completed', this.checked);
    this.checked ? $completed.addClass('hidden') : $completed.removeClass('hidden');

    console.log($('.test').not('.hidden').size());

    if ($('.test').not('.hidden').size() === 0) {
      $('#has-tests').addClass('hidden');
      $('#no-tests').removeClass('hidden');
    } else {
      $('#no-tests').addClass('hidden');
      $('#has-tests').removeClass('hidden');
    }
  });
  $('#completed').trigger('change');
});
