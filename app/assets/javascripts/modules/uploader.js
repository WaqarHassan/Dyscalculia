var Uploader = function(options) {

  var $_location = $(options.location);
  var $_file_node = $(options.file_node);
  var _template = options.template;
  var _preview_template = options.preview_template;
  var _loading_template = options.loading_template;
  var _error_template = options.error_template;
  var _image_src = options.preview_src;
  var _change_fn = function() {};

  $loader_node = $(Mustache.render(_loading_template));
  $_location.parent().append($loader_node);
  $loader_node.hide();

  // Optional arguments
  var render = function(image_name) {
    if (_image_src) {
      $_location.addClass('previewing');
      $_location.html(Mustache.render(_preview_template, {
        uploaded_image: _image_src,
        image_name: image_name || undefined
      }));
      $_location.hide();
      $_location.find('img').on('load', function() {
        $loader_node.hide();
        $_location.show();
      });

      $_location.find('img').on('error', function(e) {
        $_location.removeClass('previewing');
        $_location.html(Mustache.render(_error_template));
        $_location.show();
      });
    } else {
      $_location.removeClass('previewing');
      $_location.html(Mustache.render(_template));
    }
  };


  // Events
  $_location.on('click', function() {
    if ($_location.hasClass('previewing')) {
      return false;
    } else {
      $_file_node.click();
    }
  });

  $_location.on('click', '.remove-image', function(e) {
    e.stopPropagation();
    _image_src = undefined;
    $_file_node.val('');
    render();
    _fire_change();
  });

  $_location.on('click', '.change-image', function(e) {
    $_file_node.click();
  });

  $_file_node.on('click', function(e) {
    e.stopPropagation();
  });

  $_file_node.on('change', function(e) {
    if (this.files && this.files[0]) {
      var file = this.files[0];
      var reader = new FileReader();
      reader.onload = function (e) {
        _image_src = e.target.result;
        render(file.name);
      }
      reader.readAsDataURL(file);
    }
    _fire_change();
  });
  render();

  var _fire_change = function() {
    _change_fn.call();
  };

  var change = function(fn) { _change_fn = fn };

  return {
    change: change
  };
};
