require 'rubygems'
require 'test/unit'
require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + "/../lib/calendar_helper")

require 'flexmock/test_unit'

# require 'action_controller'
# require 'action_controller/assertions'
# require 'active_support/inflector'

class CalendarHelperTest < Test::Unit::TestCase

  # include Inflector
  # include ActionController::Assertions::SelectorAssertions
  include CalendarHelper


  def test_with_output
    output = []
    %w(calendar_with_defaults calendar_for_this_month calendar_with_next_and_previous).each do |methodname|
      output << "<h2>#{methodname}</h2>\n" +  send(methodname.to_sym) + "\n\n"
    end
    write_sample "sample.html", output
  end

  def test_simple
    assert_match %r{August}, calendar_with_defaults
  end

  def test_required_fields
    # Year and month are required
    assert_raises(ArgumentError) {
      calendar
    }
    assert_raises(ArgumentError) {
      calendar :year => 1
    }
    assert_raises(ArgumentError) {
      calendar :month => 1
    }
  end

  def test_default_css_classes
    # :other_month_class is not implemented yet
    { :table_class => "calendar",
      :month_name_class => "monthName",
      :day_name_class => "dayName",
      :day_class => "day"
    }.each do |key, value|
      assert_correct_css_class_for_default value
    end
  end

  def test_custom_css_classes
    # Uses the key name as the CSS class name
    # :other_month_class is not implemented yet
    [:table_class, :month_name_class, :day_name_class, :day_class].each do |key|
      assert_correct_css_class_for_key key.to_s, key
    end
  end

  def test_abbrev
    assert_match %r{>Mon<}, calendar_with_defaults(:abbrev => (0..2))
    assert_match %r{>M<}, calendar_with_defaults(:abbrev => (0..0))
    assert_match %r{>Monday<}, calendar_with_defaults(:abbrev => (0..-1))
  end

  def test_block
    # Even days are special
    assert_match %r{class="special_day">2<}, calendar(:year => 2006, :month => 8) { |d|
      if d.mday % 2 == 0
        [d.mday, {:class => 'special_day'}]
      end
    }
  end

  def test_first_day_of_week
    assert_match %r{<tr class="dayName">\s*<th scope='col'><abbr title='Sunday'>Sun}, calendar_with_defaults
    # testing that if the abbrev and contracted version are the same, there should be no abbreviation.
    assert_match %r{<tr class="dayName">\s*<th scope='col'>Sunday}, calendar_with_defaults(:abbrev => (0..8))
    assert_match %r{<tr class="dayName">\s*<th scope='col'><abbr title='Monday'>Mon}, calendar_with_defaults(:first_day_of_week => 1)
  end

  def test_today_is_in_calendar
    todays_day = Date.today.day
    assert_match %r{class="day.+today">#{todays_day}<}, calendar_for_this_month
  end

  def test_should_not_show_today
    todays_day = Date.today.day
    assert_no_match %r{today}, calendar_for_this_month(:show_today => false)
  end

  # HACK Tried to use assert_select, but it's not made for free-standing
  #      HTML parsing.
  def test_should_have_two_tr_tags_in_the_thead
    # TODO Use a validating service to make sure the rendered HTML is valid
    html = calendar_with_defaults
    assert_match %r{<thead><tr>.*</tr><tr.*</tr></thead>}, html
  end

  private

  def assert_correct_css_class_for_key(css_class, key)
    assert_match %r{class="#{css_class}"}, calendar_with_defaults(key => css_class)
  end

  def assert_correct_css_class_for_default(css_class)
    assert_match %r{class="#{css_class}"}, calendar_with_defaults
  end

  def calendar_with_defaults(options={})
    options = { :year => 2006, :month => 8 }.merge options
    calendar options
  end

  def calendar_for_this_month(options={})
    options = { :year => Time.now.year, :month => Time.now.month}.merge options
    calendar options
  end

  def calendar_with_next_and_previous
    calendar_for_this_month({
      :previous_month_text => "PREVIOUS",
      :next_month_text => "NEXT"
    })
  end

  def write_sample(filename, content)
    FileUtils.mkdir_p "test/output"
    File.open("test/output/#{filename}", 'w') do |f|
      f.write %(<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html><head><title>Stylesheet Tester</title><link href="../../generators/calendar_styles/templates/grey/style.css" media="screen" rel="Stylesheet" type="text/css" /></head><body>)
      f.write content
      f.write %(</body></html>)
    end
  end

end
