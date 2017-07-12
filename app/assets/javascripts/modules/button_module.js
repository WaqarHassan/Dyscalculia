var buttonModule = (function(node) {
  var $_node = $(node);
  var _enabled = true;
  var _visible = true;

  var enable = function() {
    _enabled = true;
    $_node.removeClass('disabled');
  };

  var disable = function() {
    _enabled = false;
    $_node.addClass('disabled');
  };

  var hide = function() {
    _visible = true;
    $_node.removeClass('visible');
  };

  var show = function() {
    _visible = false;
    $_node.addClass('visible');
  };

  var on_click = function() {

  };

  return {
    enabled: _enabled,
    disabled: !_enabled,
    visible: _visible,
    enable: enable,
    disable: disable,
    hide: hide,
    show: show,
    on_click: on_click
  }

})();
