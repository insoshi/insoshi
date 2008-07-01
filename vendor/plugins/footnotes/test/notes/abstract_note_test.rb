require File.dirname(__FILE__) + '/../test_helper'

class AbstractNoteTest < Test::Unit::TestCase
  def setup
    @note = Footnotes::Notes::AbstractNote.new
    Footnotes::Filter.notes = [:abstract]
  end

  def test_respond_to_start_and_close
    assert_respond_to Footnotes::Notes::AbstractNote, :start!
    assert_respond_to Footnotes::Notes::AbstractNote, :close!
  end
  
  def test_respond_to_sym
    assert_equal :abstract, Footnotes::Notes::AbstractNote.to_sym
    assert_equal :abstract, @note.to_sym
  end

  def test_respond_to_included?
    assert Footnotes::Notes::AbstractNote.included?
    assert @note.included?
    Footnotes::Filter.notes = []
    assert !Footnotes::Notes::AbstractNote.included?
    assert !@note.included?
  end

  def test_respond_to_row
    assert_equal :show, @note.row
  end
  
  def test_respond_to_title
    assert_respond_to @note, :title
  end
  
  def test_respond_to_legend
    assert_respond_to @note, :legend
  end

  def test_respond_to_content
    assert_respond_to @note, :content
  end

  def test_respond_to_link
    assert_respond_to @note, :link
  end

  def test_respond_to_onclick
    assert_respond_to @note, :onclick
  end

  def test_respond_to_stylesheet
    assert_respond_to @note, :stylesheet
  end

  def test_respond_to_javascript
    assert_respond_to @note, :javascript
  end

  def test_respond_to_valid?
    assert_respond_to @note, :valid?
    assert !@note.valid?
  end

  def test_respond_to_fieldset?
    assert_respond_to @note, :fieldset?
    assert !@note.fieldset?
  end
  
  def test_footnotes_prefix
    assert !@note.send(:prefix?)
    Footnotes::Filter.prefix = 'texteditor://open?url=file://'
    assert @note.send(:prefix?)
  end
  
  def test_footnotes_escape
    assert_equal '&lt;', @note.send(:escape,'<')
    assert_equal '&amp;', @note.send(:escape,'&')
    assert_equal '&gt;', @note.send(:escape,'>')
  end
  
  def test_footnotes_mount_table
    assert_equal '', @note.send(:mount_table,[])
    assert_equal '', @note.send(:mount_table,[['h1','h2','h3']], :class => 'table')

    tab = <<-TABLE
          <table class="table">
            <thead><tr><th>H1</th></tr></thead>
            <tbody><tr><td>r1c1</td></tr></tbody>
          </table>
          TABLE

    assert_equal tab, @note.send(:mount_table,[['h1'],['r1c1']], :class => 'table')

    tab = <<-TABLE
          <table >
            <thead><tr><th>H1</th><th>H2</th><th>H3</th></tr></thead>
            <tbody><tr><td>r1c1</td><td>r1c2</td><td>r1c3</td></tr></tbody>
          </table>
          TABLE

    assert_equal tab, @note.send(:mount_table,[['h1','h2','h3'],['r1c1','r1c2','r1c3']])

    tab = <<-TABLE
          <table >
            <thead><tr><th>H1</th><th>H2</th><th>H3</th></tr></thead>
            <tbody><tr><td>r1c1</td><td>r1c2</td><td>r1c3</td></tr><tr><td>r2c1</td><td>r2c2</td><td>r2c3</td></tr></tbody>
          </table>
          TABLE

    assert_equal tab, @note.send(:mount_table,[['h1','h2','h3'],['r1c1','r1c2','r1c3'],['r2c1','r2c2','r2c3']])
  end
end