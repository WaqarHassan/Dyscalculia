module ApplicationHelper
  require 'chronic_duration'

  def nav_link_to(current_identifier, *args, &block)
    identifier = block_given? ? args[1].delete(:identifier) : args[2].delete(:identifier)
    content_tag :li, class: (:active if identifier == current_identifier) do
      link_to(*args, &block)
    end
  end

  def navbar_link_to(*args, &block)
    nav_link_to(@current_nav_identifier, *args, &block)
  end

  def subnav_link_to(*args, &block)
    nav_link_to(@current_subnav_identifier, *args, &block)
  end

  def no_record_tr(colspan, text = 'No records to display')
    content_tag(:tr, content_tag(:td, text, colspan: colspan, class: 'text-center text-muted' ), class: 'tr-no-record')
  end

  def partial_exist?(partial_name, prefixes = lookup_context.prefixes)
    lookup_context.exists?(partial_name, prefixes, true)
  end

  def front_end_template(id)
    haml_tag :script, :id => id, :type => "x-tmpl-mustache" do
      yield
    end
  end

  def render_loader
    tag(:img, :class=>'loader', :src => '/images/loader.gif', :alt => 'Loading...')
  end

  def letter_to_number(id)
    (65+id%25).chr
  end

  def friendly_time(seconds)
    ChronicDuration.output(seconds || 0)
  end

  def friendlier_time(seconds)
    days = (seconds/1.days).to_i
    hours = (seconds/1.hours).to_i
    minutes = (seconds/1.minutes).to_i
    if seconds >= 1.days
      "#{pluralize(days, 'day')}"
      # and #{pluralize(((seconds%1.days)/1.hours).to_i,'hour')}"
    elsif seconds < 1.days && seconds > 1.hours
      "#{pluralize(hours, 'hour')}"
      # and #{pluralize(((seconds%1.hours)/1.minutes).to_i,'minutes')}"
    elsif seconds < 1.hours && seconds > 1.minutes
      "#{minutes} minutes"
    else
      "#{pluralize((seconds%1.minutes).to_i,'second')}"
      #{pluralize(minutes,'minute')} and
    end
  end

  def friendly_date(date)
    if date
      date.strftime('%B %d, %Y')
    end
  end

  def relative_time(future_time,past_time)
    seconds = future_time - past_time
    return friendlier_time(seconds)
    # return seconds
  end

  def format_value(value)
    value ||= '-'
  end
end
