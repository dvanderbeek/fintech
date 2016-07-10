Dir.glob(File.join('./lib', 'fintech', '**', '*.rb'), &method(:require))
require 'ostruct'
require 'pry'
require 'benchmark'

module Fintech
end
