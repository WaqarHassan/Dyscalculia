//= require mathquill
//= require mustache
//= require jquery-ui
//= require modules/question_module
//= require modules/button_module
//= require modules/uploader
//= require modules/equation

$(function(){

    // Cache DOM
    var $question_module_loc = $('#question-module');
    var $question_form = $('#question-form');
    var $save_button = $('#save');
    var $question_text = $('#question-text');
    var $question_type = $('#question-type-header');
    var $save_button_location = $('#save-button-location');
    var $curriculum_reference = $('#curriculum-reference');
    var $choices = $('#choices');


    // Get question data
    var question_type = $question_module_loc.data('question-type');
    var question_answers = $question_module_loc.data('answers') || [];

    // Templates
    var multiple_choice_answer_template = $('#multiple-choice-template').html();
    var multi_answer_node_template = $('#multi-answer-node-template').html();
    var input_answer_node_template = $('#input-answer-node-template').html();
    var input_answer_template = $('#input-template').html();
    var save_button_template = $('#save_button_template').html();

    var header_template = $('#header-template').html();

    // Buttons
    var $toggle_button = $('#toggle-question');

    // Setup modules
    var mq_module = QuestionModule($question_module_loc, '#multi-answer-module', multiple_choice_answer_template, multi_answer_node_template);
    var input_module = QuestionModule($question_module_loc, '#input-answer-module', input_answer_template, input_answer_node_template);

    $('.click-uploader').each(function() {
        var u = Uploader({
          location: $(this).find('.inner'),
          file_node: $(this).find($('input[type="file"]')),
          template: $(this).find('#before-upload-template').html(),
          preview_template: $(this).find('#previewing-template').html(),
          loading_template: $(this).find('#loading-image-template').html(),
          error_template: $(this).find('#loading-error-template').html(),
          preview_src: $(this).data('image-src') || undefined
        });
        u.change(function() {
          $question_module_loc.trigger('edited');
        });
    });

    var eq = Equation($('.equation-module'));
    eq.change(function() {
      $question_module_loc.trigger('edited');
    });

    $curriculum_reference.on('keydown', function() {
      $question_module_loc.trigger('edited');
    });

    $question_text.on('keydown', function() {
      $question_module_loc.trigger('edited');
    });

    mq_module.change(function() {
      $question_module_loc.trigger('edited');
    });

    input_module.change(function() {
      $question_module_loc.trigger('edited');
    });



    // Defaults to two choices
    mq_module.set_answers(question_answers);

    // Defaults to one answer
    input_module.set_answers(question_answers);


    $toggle_button.on('click', function() {
      module_toggler.fire();
      $question_module_loc.trigger('edited');
      return false;
    });

    $save_button_location.on('click', '#save', function() {
      saving = true
      $question_form.submit();
      $save_button_location.html(Mustache.render(save_button_template, {
        dirty: false,
        clean: false,
        saving: true,
        canceling: false
      }));
    });

    $save_button_location.on('click', '#cancel', function() {
      if (confirm($(this).data('message'))) {
        $save_button_location.html(Mustache.render(save_button_template, {
          dirty: false,
          clean: false,
          saving: false,
          canceling: true
        }));
        dirty = false;
        return true;
      }
      return false;
    });


    var dirty = !!$save_button_location.data('dirty')
    var saving = false

    // Render a button if server hasnt
    if (!$save_button_location.has('button').length) {
      $save_button_location.html(Mustache.render(save_button_template, {
        dirty: dirty,
        clean: !dirty,
        saving: false,
        canceling: false
      }));
    }

    $question_module_loc.on('edited', function() {
      if (!dirty) {
        dirty = true;
        $save_button_location.html(Mustache.render(save_button_template, {
          dirty: dirty,
          clean: !dirty,
          saving: false
        }));
      }
    });

    $choices.on('click', '.btn', function() {
      $(this).addClass('btn-primary');
      $(this).siblings('.btn').removeClass('btn-primary');

      var type = $(this).data('type');

      if (type === 'MultipleChoiceQuestion') {
        if (question_answers.length < 2) {
          mq_module.add_answer({}, false);
          if (question_answers.length === 1)
            mq_module.add_answer({}, false);
        }
      }

      if (type === 'InputQuestion') {
        if (!question_answers.length)
          mq_module.add_answer({},false);
      }

      type === 'MultipleChoiceQuestion' && mq_module.render();
      type === 'InputQuestion' && input_module.render();

      $question_type.html(Mustache.render(header_template, {
        multiple_choice: type === 'MultipleChoiceQuestion',
        input_question: type === 'InputQuestion'
      }));

    });

    $choices.find('[data-type='+question_type+']').click();

    $('#question-form').on('input change','input', function() {
      $question_module_loc.trigger('edited');
    });

    deleting = false;
    $('#delete').click(function() {
      if (confirm($(this).data('message'))) {
        deleting = true;
        return true;
      }
      return false;
    });

    window.onbeforeunload = function() {
      if (dirty && !saving && !deleting) {
        return 'Unsaved changes detected, are you sure you want to leave?'
      }
    };

});
