$:.unshift 'lib'
require 'microformat'

class XOXO < Microformat
  @@parents  = %w[ol ul]
  @@children = %w[li]

  xpath_build =  proc { |element| element.map { |e| "/#{e}" } * ' | '  }
  @@children_xpath = xpath_build[@@children]
  @@parents_xpath  = xpath_build[@@parents]

  def self.find_first(doc)
    find_every(doc).first
  end

  def self.find_every(doc)
    doc.map { |child| build_tree(child) }
  end

  def self.find_occurences(doc)
    @options[:class] ? doc/".xoxo" : doc.search(@@parents_xpath)
  end

  def self.build_tree(child)
    tree = []
    child.search(@@children_xpath) do |element|
      label, branch = nil, nil
      element.children.each do |inner|
        label  ||= build_label(inner) unless container?(inner)
        branch ||= build_tree(inner) if container?(inner)
      end
      tree << (branch ? { label => branch } : label)
    end 
    tree
  end

  def self.container?(el)
    el.elem? && @@parents.include?(el.name)
  end

  def self.build_label(node)
    if node.elem? 
      label = Label.new(node.innerHTML.strip)
      label.url = node['href'] if node.name == 'a'
      label
    elsif node.text? && !node.to_s.strip.empty?
      node.to_s.strip 
    end
  end

  class Label < String
    attr_accessor :url
  end
end
