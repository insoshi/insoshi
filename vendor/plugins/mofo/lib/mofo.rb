$:.unshift File.dirname(__FILE__)

Dir["#{File.dirname(__FILE__)}/mofo/*.rb"].each { |format| require "mofo/#{File.basename format}" }
