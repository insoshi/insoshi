class String
  # Replace the second of three capture groups with the given block.
  def midsub(regexp, &block)
    self.gsub(regexp) { $1 + yield($2) + $3 }
  end
end

# Wrap words at given width.
# This is an improvement over the built-in word_wrap because it splits
# up long words even if there isn't a whitespace separator.
def wordwrap(text, width=80, string="\n")
  text.midsub(%r{(\A|</pre>)(.*?)(\Z|<pre(?: .+?)?>)}im) do |outside_pre|  
    # Not inside <pre></pre>
    outside_pre.midsub(%r{(\A|>)(.*?)(\Z|<)}m) do |outside_tags|
      # Not inside < >, either
      outside_tags.gsub(/(\S{#{width}})(?=\S)/) { "#$1#{string}" }
    end
  end
end