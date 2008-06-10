# => http://microformats.org/wiki/hatom
require 'microformat'
require 'mofo/hcard'
require 'mofo/rel_tag'

class HEntry < Microformat
  one :entry_title, :entry_summary, :updated, :published,
      :author => HCard

  many :entry_content, :tags => RelTag 

  after_find do
    @updated = @published unless @updated if @published
  end
end
