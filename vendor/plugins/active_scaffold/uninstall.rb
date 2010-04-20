##
## Delete public asset files
##

require 'fileutils'

directory = File.dirname(__FILE__)

[ :stylesheets, :javascripts, :images].each do |asset_type|
  path = File.join(directory, "../../../public/#{asset_type}/active_scaffold")
  FileUtils.rm_r(path)
end
FileUtils.rm(File.join(directory, "../../../public/blank.html"))
