require 'optparse'
require 'syslog'
require 'io/wait'
require 'elesai'
require 'elesai/action'
require 'elesai/version'
require 'elesai/about'

include Elesai::Action

module Elesai

  class CLI

    COMMANDS = %w(show check)

    def initialize(arguments)
      @arguments = arguments
      @whoami = File.basename($PROGRAM_NAME).to_sym

      @options = { :debug => false, :megacli => 'MegaCli' }
      @action_options = { :monitor => :nagios, :mode => :active }
      @action = nil
      @foo = nil
    end

    def run
      begin
        parsed_options?

        @log = Elesai::Logger.instance.log
        @log.level = Log4r::INFO unless @options[:debug]

        arguments_valid?
        options_valid?
        process_options
        process_arguments
        process_command

      rescue => e #ArgumentError, OptionParser::MissingArgument, Senedsa::SendNsca::ConfigurationError => e
        if @options[:debug]
          output_message "#{e.class}: #{e.message}\n  #{e.backtrace.join("\n  ")}",1
        else
          output_message e.message,1
        end
      end
    end

    protected

      def parsed_options?
        opts = OptionParser.new

        opts.banner = "Usage: #{ID} [options] <action> [options]"
        opts.separator ""
        opts.separator "Actions: (<action> -h displays help for specific action)"
        opts.separator "    show                             Displays component information"
        opts.separator "    check                            Performs health checks"
        opts.separator ""
        opts.separator "General options:"
        opts.on('-m', '--megacli MEGACLI',                String,              "Path to MegaCli binary")                             { |megacli| @options[:megacli] = megacli }
        opts.on('-f', '--fake DIRECTORY',                 String,              "Path to directory with Megacli output")              { |dir| @options[:fake] = dir }
        opts.on('-d', '--debug',                                               "Enable debug mode")                                  { @options[:debug] = true}
        opts.on('-a', '--about',                                               "Display #{ID} information")                          { output_message ABOUT, 0 }
        opts.on('-V', '--version',                                             "Display #{ID} version")                              { output_message VERSION, 0 }
        opts.on_tail('--help',                                                 "Show this message")                                  { @options[:HELP] = true }

        opts.order!(@arguments)
        output_message opts, 0 if (@arguments.size == 0 and @whoami != :check_lsi) or @options[:HELP]

        @action = @whoami == :check_lsi ? :check : @arguments.shift.to_sym
        case @action
          when :show then  @elesai = Show.new(@arguments,@options)
          when :check then @elesai = Check.new(@arguments,@options)
          else raise OptionParser::InvalidArgument, "invalid action #@action"
        end
      end

      def arguments_valid?
        true
      end

      def options_valid?
        true
      end

      def process_options
        true
      end

      def process_arguments
        @action_options[:hint] = @arguments[0].nil? ? nil : @arguments[0].to_sym
        true
      end

      def process_command
        @elesai.exec
      end

      def output_message(message, exitstatus=nil)
        m = (! exitstatus.nil? and exitstatus > 0) ? "%s: error: %s" % [ID, message] : message
        Syslog.open("elesai", Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.err "error: #{message}" } unless @options[:debug]
        $stderr.write "#{m}\n" if STDIN.tty?
        exit exitstatus unless exitstatus.nil?
      end

  end
end