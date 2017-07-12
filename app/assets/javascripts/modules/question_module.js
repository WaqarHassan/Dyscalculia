// Requires the html has a #answers container, with the desired answer nodes being immediate children
// of this container

// In order to delete questions a button with data-action-delete=[index to delete] can be used
// likewise for data-action-add=1, set-as-answer=id and set-as-not-answer=id

// The module requires two templates, one for the whole module and another for the answer nodes contained InputQuestionModule
// of the view.

// The views will have access to answer objects with attributes letter, index, answer_text and is_answer


var QuestionModule = function(location, id, template, answer_template) {

  var $_location = $(location);
  var $_module;
  var _template = template;
  var _answer_template = answer_template
  var _answers = [];
  var change_fn = function() {};

  // Converts an int (starting from 0) to a letter and repeats
  var _calc_letter = function(i) { return String.fromCharCode(i%26+65) };

  // Renders a new answer
  var _render_answer = function(answer, index) {
    return Mustache.render(_answer_template, {
      letter: _calc_letter(index),
      index: index,
      answer_text: answer.answer_text,
      is_answer: answer.is_answer
    });
  };

  // Re-renders node but keeps value in input
  var _render_update_all = function() {
    $_module = $_module || $(id);
    $_module.find('#answers').children('.input-group').each(function(i) {

      var $this = $(this);
      var text = $this.find('.answer-input').val();

      $this.remove();
      $_location.find('#answers').append(_render_answer({
        answer_text: text,
        is_answer: _answers[i].is_answer
      }, i));
    });
    _fire_change()
  };

  var _fire_change = function() {
    change_fn.call();
  };

  // Renders all the answers
  var render = function() {
    var question_count = -1;

    var updated_answers = $.map(_answers, function(answer){
      question_count ++;
      return {
        letter: _calc_letter(question_count),
        index: question_count,
        answer_text: answer.answer_text,
        is_answer: answer.is_answer
      }
    });

    $_location.html(Mustache.render(_template, {
      answers: updated_answers
    },{
      answer_partial: _answer_template
    }));

    $_module = $(id);
    _bind_events();
    $_module.find('#answers.sortable').sortable({
      stop: function(){
        var new_order = $(this).sortable('toArray');

        var temp_array = [];
        $.each(_answers, function(i, answer){
          var new_index = parseInt(new_order[i]);
          temp_array[i] = _answers[new_index];
        });
        _answers = temp_array;
        _render_update_all();
      }
    });
  };

  var set_answers = function(answers) {
    _answers = answers || _answers;
  };

  var add_answer = function(answer, render) {
    var sanitised_answer = {
      answer_text: answer.answer_text,
      is_answer: answer.is_answer || false
    };
    _answers.push(sanitised_answer);
    if (render) $_module.find('#answers').append(
      _render_answer(sanitised_answer, _answers.length-1));
    _fire_change()
  };

  var remove_answer = function(index, render) {
    _answers.splice(index, 1);

    if (render) {
      var answer_container = $_module.find('#answers');
      answer_container.children().eq(index).remove();
      _render_update_all();
    }
  };

  var change = function(fn) {
    change_fn = fn;
  };

  // === Events
  var _bind_events = function() {
    $($_module).on('click','[data-action-add]', function(){
      add_answer({}, true);
    });

    $($_module).on('input','input[type="text"]', function(){
      _fire_change();
    });

    $($_module).on('click', '[data-action-delete]', function() {
      remove_answer($(this).data('action-delete'), true);
    });

    $($_module).on('click', '[data-action-set-as-answer]', function() {
      $this = $(this);
      $.each(_answers, function(i){
        if (i === parseInt($this.data('action-set-as-answer'))) {
          _answers[i].is_answer = true;
        } else {
          _answers[i].is_answer = false;
        }
      });
      _render_update_all();
    });

    $($_module).on('click', '[data-action-set-as-not-answer]', function() {
      _answers[$(this).data('action-set-as-not-answer')].is_answer = false;
      _render_update_all();
    });
  }

  return {
    set_answers: set_answers,
    add_answer: add_answer,
    answer_count: _answers.length,
    remove_answer: remove_answer,
    change: change,
    render: render
  };

};
