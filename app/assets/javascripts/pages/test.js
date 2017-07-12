


$(function(){
  var time_from_before = parseInt($('#time-taken').val()) || 0;
  var $message = $('#warning-message');
  var start = Date.now()-time_from_before;
  var stop = false;
  var xhr;
  var waiting_for_server = false

  $('#extend').click(function() {
    $(this).parent().addClass('hidden');
    waiting_for_server = true;
    setTimeout(function() {
      waiting_for_server = false;
    }, 15000);
    $.ajax({ url: location.href+'/extend_time', success: function(data) {
    }, dataType: "json", method: 'put'});
  });

  // Auto savetime time after 1 second
  (function poll() {
    if (stop) return;
    setTimeout(function() {

      xhr = $.ajax({ url: location.href+'/submit_time', success: function(data) {
        console.log(data.time_left);
        if (data.time_left <= 0) {
          if (waiting_for_server)
            poll();
          else
            location.reload();
        } else if (data.time_left <= 10000){
          if (!waiting_for_server)
            $message.removeClass('hidden');
          poll();
        } else {
            $message.addClass('hidden');
            poll();
        }
      }, dataType: "json", method: 'put', data: {time: (Date.now() - start)}});
    }, 1000);
  })();

  $('#question-form').on('submit', function(e) {
    // Ensure no futher requests are made while the
    // form is being submitted
    stop = true;
    if(xhr) xhr.abort();
    $('#time-taken').val(Date.now() - start);
    return true;
  });

  $('.audio-speaker').each(function() {
    var $this = $(this);
    var $icon = $this.find('.icon');
    var $audio = $this.find('audio');

    $audio.on('play', function(e) {
      var fa = $(e.target).siblings('.icon').find('.fa');
      fa.removeClass('fa-volume-off');
      fa.addClass('fa-volume-up');
    });

    $audio.on('pause', function(e) {
      var fa = $(e.target).siblings('.icon').find('.fa');
      fa.removeClass('fa-volume-up');
      fa.addClass('fa-volume-off');
    });


    $this.on('click', function() {

      if ($audio[0].paused) {
        $audio[0].play();
      } else {
        $audio[0].pause();
        $audio[0].currentTime = 0;
      }

    });

  });

  var answers = $('.answers');
  var submit_btn = $('#submit');
  answers.find('.answer').on('click', function() {
    submit_btn.removeClass('hidden');
    submit_btn.addClass('animated bounceIn');
  });

  var typing_timer;
  var done_typing_interval = 200;

  //on keyup, start the countdown
  $('.answer').keyup(function(){
      clearTimeout(typing_timer);
      if ($('.answer').val() !== '') {
          typing_timer = setTimeout(done_typing, done_typing_interval);
      } else {
        submit_btn.removeClass('animated bounceIn');
        submit_btn.addClass('animated bounceOut');
      }
  });

  function done_typing () {
    submit_btn.removeClass('hidden');
    submit_btn.removeClass('animated bounceOut');
    submit_btn.addClass('animated bounceIn');
  }
});
