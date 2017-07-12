// *= Mustache
var AudioUploader = function(options) {
  var $_location = $(options.location);
  var $_file_node = $(options.file_node);
  var _template = options.template;
  var _audio_src = options.audio_src;

  if (_audio_src) {
    $_location.html(Mustache.render(_template, {
      previewing: true,
      question_reading: _audio_src
    }));
  } else {
    $_location.html(Mustache.render(_template, {
      empty: true
    }));
  }

  $_file_node.on('change', function(e) {

    if (this.files && this.files[0]) {

      $_location.html(Mustache.render(_template, {
        loading: true
      }));


      var file = this.files[0];
      var reader = new FileReader();
      reader.onload = function (e) {
        _audio_src = e.target.result;
        $_location.html(Mustache.render(_template, {
          previewing: true,
          question_reading: _audio_src
        }));
      }
      reader.readAsDataURL(file);
    }
  });


  $_location.on('click', '[data-action-remove]', function() {
    $_location.html(Mustache.render(_template, {
      previewing: false,
      upload_failed: false,
      empty: true,
      question_reading: _audio_src
    }));
    $_file_node.trigger('change');
    $_file_node.val('');
  });

  $_location.on('click', '[data-action-upload]', function() {
    $_file_node.click();
  });

  $_location.on('click', '[data-action-change]', function() {
    $_file_node.click();
  });

};

// Default behaviour
$(function() {
  $('.audio-uploader').each(function() {
    AudioUploader({
      location: $(this).find('.inner'),
      template: $(this).find('#upload-template').html(),
      file_node: $(this).find('[type=file]'),
      audio_src: $(this).data('audio-src')
    });
  });
});
