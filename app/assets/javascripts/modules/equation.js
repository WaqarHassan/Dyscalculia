//= mathquill
//= mustache

var Equation = function(location) {
  var $_location = $(location);
  var $_equation_location = $_location.find('.equations');

  var _equation_template = $_location.find('#equation-template').html();
  var _equations = [];
  var data = $_location.data('equations');
  var _change_fn = function() {};

  var mathquillify = function (node) {
    var $_equations_value_field = $(node).siblings('.equation-value');
    var MQ = MathQuill.getInterface(2);
    var mathField = MQ.MathField(node, {
      spaceBehavesLikeTab: true,
      handlers: {
        edit: function() {
            $_equations_value_field.val(mathField.latex());
            _change_fn.call();
          }
        }
    });
    return mathField;
  };

  var add = function(render, text) {
    var id = _equations.length;
    $node = $(Mustache.render(_equation_template, {id: id, text: text || ''}));
    var mf = mathquillify($node.find('.text-field')[0]);

    _equations.push({
      text: text || '',
      $node: $node,
      mf: mf
    });

    if (render) {
      $_equation_location.append($node);
    }
  };

  var remove = function(id, render_after) {
    _equations.splice(id, 1);
  };

  $_location.on('click', '[data-action-add]', function() {
    _change_fn.call();
    add(true);
  });

  $_location.on('click', '[data-action-delete]', function() {
    _change_fn.call();
    var id = $(this).data('action-delete');
    remove(id);
    render();
  });


  var render = function() {
    $_equation_location.html('');
    $.each(_equations, function(i, e) {
      var $node = $(Mustache.render(_equation_template, {id: i, text: e.mf.latex()}));
      _equations[i].mf = mathquillify($node.find('.text-field')[0]);
      _equations[i].$node = $node;
      _equations[i].text = e.mf.latex();
      $_equation_location.append($node);
    });
  };

  // If data from server render it straight away
  if (data) {
    $.each(data, function(_, e) {
      add(true, e.text);
    });
  }

  var _set_change = function(fn) {
    _change_fn = fn;
  }

  return {
    render: render,
    add: add,
    remove: remove,
    equations: _equations,
    change: _set_change
  }
};
