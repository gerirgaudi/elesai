require 'singleton'
require 'log4r'

module Elesai

  class Logger

    include Singleton

    attr_reader :log

    def initialize
      @log = Log4r::Logger.new("elesai")
      @log.add Log4r::StderrOutputter.new('console', :formatter => Log4r::PatternFormatter.new(:pattern => "%c [%l] %m"), :level => Log4r::DEBUG)
    end

  end
end