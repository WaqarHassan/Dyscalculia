# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( pages/edit_question.js )
Rails.application.config.assets.precompile += %w( pages/edit_test.js )
Rails.application.config.assets.precompile += %w( jquery-ui.js )
Rails.application.config.assets.precompile += %w( pages/test.js )
Rails.application.config.assets.precompile += %w( pages/sign_up.js )
Rails.application.config.assets.precompile += %w( pages/user_overview.js )
Rails.application.config.assets.precompile += %w( pages/user_overview.sass )
Rails.application.config.assets.precompile += %w( pages/edit_question.sass )
Rails.application.config.assets.precompile += %w( pages/test.sass )
Rails.application.config.assets.precompile += %w( pages/base.sass )
Rails.application.config.assets.precompile += %w( animate.sass )
Rails.application.config.assets.precompile += %w( modules/audio_uploader.js )
Rails.application.config.assets.precompile += ['katex.css', 'katex.js']
Rails.application.config.assets.precompile += ['mathquill.css', 'mathquill.js']
Rails.application.config.assets.precompile += ['modules/equation.sass', 'modules/equation.js']
