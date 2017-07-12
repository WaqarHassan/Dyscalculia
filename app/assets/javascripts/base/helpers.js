var Toggler = (function() {

  function Toggler(fns) {

    if (Number.isInteger(fns[fns.length-1])){
      this.current = fns[fns.length-1];
      this.fns = fns.splice(0, fns.length-1);
    } else {
      this.current = 0;
      this.fns = fns;
    }
  }

  Toggler.prototype.fire = function() {
     this.fns[this.current].call();
     this.current = (this.current + 1) % this.fns.length;
  }


  return function() {
    return new Toggler(Array.prototype.slice.call(arguments));
  }

})();

// http://stackoverflow.com/questions/2897155/get-cursor-position-in-characters-within-a-text-input-field
(function($) {
    $.fn.getCursorPosition = function() {
        var input = this.get(0);
        if (!input) return; // No (input) element found
        if ('selectionStart' in input) {
            // Standard-compliant browsers
            return input.selectionStart;
        } else if (document.selection) {
            // IE
            input.focus();
            var sel = document.selection.createRange();
            var selLen = document.selection.createRange().text.length;
            sel.moveStart('character', -input.value.length);
            return sel.text.length - selLen;
        }
    }
})(jQuery);

// http://stackoverflow.com/questions/512528/set-cursor-position-in-html-textbox
function setCaretPosition(elem, caretPos) {

    if(elem != null) {
        if(elem.createTextRange) {
            var range = elem.createTextRange();
            range.move('character', caretPos);
            range.select();
        }
        else {
            if(elem.selectionStart) {
                elem.focus();
                elem.setSelectionRange(caretPos, caretPos);
            }
            else
                elem.focus();
        }
    }
}



var helpers = {
  all: function(array, fn) {
    var flag = true;
    $.each(array, function(_, element) {
      if (!fn(element)) {
        flag = false;
      }
    });
    return flag;
  },

  toggle: function() {
    var fns = Array.prototype.slice.call(arguments, 0, arguments.length-1);
    var evt = arguments[arguments.length-1];
  }
};

$(function() {
  $('.render-latex').each(function(){
    katex.render(htmlDecode($(this).html()), this, {displayMode: true});
  });

  function htmlDecode(input){
    var e = document.createElement('div');
    e.innerHTML = input;
    return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
}

  $('.render-latex-inline').each(function(){
    katex.render(htmlDecode($(this).html()), this, {displayMode: false});
  });

  $('.time-picker').each(function(i, el) {
    $(this).find('input').focus(function() {
      $(this).blur();
      $(this).attr('tabindex','-1');
    });

    $that = $(this);
    $main_input = $(this).find('input');

    var total = $(this).find('input').val() || 0;
    var mins = Math.floor(total / 60);
    var seconds = total % 60

    var up_control = $('<div data-direction="1" class="up fa fa-chevron-up"></div>');
    var down_control = $('<div data-direction="-1" class="down fa fa-chevron-up"></div>');
    var mins = $('<div class="mins"><input value="'+mins+'" maxlength="2" id="mins" type="text" placeholder="--"><label for="mins">Mins</label></div>');
    var seconds = $('<div class="secs"><input value="'+seconds+'" maxlength="2" id="secs" type="text" placeholder="--"><label for="secs">Secs</label></div>');
    $(this)
      .append(up_control)
      .append(down_control)
      .append(mins)
      .append(seconds);

    mins.add(seconds).on('input', function() {
      $main_input.val(parseInt($that.find('#mins').val() || 0)*60+parseInt($that.find('#secs').val() || 0));
      $main_input.trigger('input');
    });

    function change_number(input, direction) {
      if (input.value !== undefined) {
        input.value = (60+parseInt(input.value) + 1 * direction)%60;
      }
      $main_input.val(parseInt($that.find('#mins').val() || 0)*60+parseInt($that.find('#secs').val() || 0));
      $main_input.trigger('input');
    }

    up_control.add(down_control).on('mousedown', function(e) {
      e.preventDefault();
      var input = $(this).siblings('.mins, .secs').find('input:focus');
      if (input.size()) {
        change_number(input[0], $(this).data('direction'));
      } else {
        var input = $(this).siblings('.mins, .secs').find('input')[0];
        input.focus();
        change_number(input, $(this).data('direction'));
      }
    });

    var Key = {up: 38, down: 40 };

    mins.add(seconds).on('keydown', function(e) {
      var input = $(this).find('input')[0];
      if (e.keyCode === Key.up) {
        e.preventDefault();
        change_number(input, 1);
      } else if (e.keyCode === Key.down) {
        e.preventDefault();
        change_number(input, -1);
      }
    });
  });

  $('.input-helper').each(function(i, el) {
    var $input = $(this).find('input');
    var $inputs = $(this).find('.inputs');
    $inputs.hide();
    var inputting = false;
    $input.on({
      focus: function() {
        $inputs.fadeIn(200);
      },
      blur: function(e) {
        $inputs.fadeOut(200);
      }
    });

    $(this).on('mousedown', 'li', function(e) {
      e.preventDefault();
      var str = this.innerHTML;
      var position = $input.getCursorPosition();
      $input[0].value = [$input[0].value.slice(0, position),str, $input[0].value.slice(position)].join('');
      $input.trigger('input');
      setCaretPosition($input[0], position+1);
    });
  });

  $('.otherise').each(function() {
    $(this).find('select').append('<option value="other">'+ $(this).data('select-message') || 'Other' +'</other>');
    $(this).append('<div class="other-field"></div>');
    var message = $(this).data('message');
    var $that = $(this);
    $that.find('select').change(function() {
      var el = $(this)[0];
      console.log(el.options[el.selectedIndex].value);

      if (el.options[el.selectedIndex].value === 'other') {
        var name = $that.find('select').attr('name');
        var $element = $('<label class="margin-left-25 margin-bottom-25">'+ message +'</><input autofocus class="form-control" type="text" name='+ name +'>');
        $that.find('.other-field').html($element);
      } else {
        $that.find('.other-field').html('');
      }
    });
  });

  $('[data-show-element]').click(function() {
    $($(this).data('show-element')).removeClass('hidden');
    return false;
  });
});
