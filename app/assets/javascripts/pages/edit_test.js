//= require mustache

$(function(){
  var $location = $('#render-save-button');
  var template = $('#save_button_template').html();

  var dirty = false;

  $('body').on('change', '#duration select', function() {
    if (!dirty) {
        dirty = true;
        $location.html(Mustache.render(template, {clean: false, dirty: true, saving: false, canceling: false}));
    }
  });

  $('body').on('input', '#title input', function() {
    if (!dirty) {
        dirty = true;
        $location.html(Mustache.render(template, {clean: false, dirty: true, saving: false, canceling: false}));
    }
  });

  $('body').on('click', '#save', function() {
    $(this).parent('form').submit();
    setTimeout(function() {
      $location.html(Mustache.render(template, {clean: false, dirty: false, saving: true, canceling: false}));
    }, 10);
  });

  $('body').on('click', '#cancel', function() {
    if (confirm($(this).data('message'))) {
      $location.html(Mustache.render(template, {clean: false, dirty: false, saving: false, canceling: true}));
    } else {
      return false;
    }
  });

  $location.html(Mustache.render(template, {clean: true, dirty: false, saving: false, canceling: false}));
});
