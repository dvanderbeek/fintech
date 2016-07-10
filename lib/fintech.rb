Dir.glob(File.join('./lib', 'fintech', '**', '*.rb'), &method(:require))
require 'ostruct'
require 'pry'

module Fintech
end
