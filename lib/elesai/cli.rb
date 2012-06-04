require 'trollop'
require 'senedsa'
include Senedsa
require 'elesai/version'
require 'elesai/about'

module Elesai

  class CLI

    COMMANDS = %w(show check)
    COMPONENTS = %w(virtualdrive vd physicaldrive pd)

    def initialize(argv)
      @argv = argv

      parse_global_options
      parse_command
      parse_arguments

      @log = Elesai::Logger.instance.log
      @log.level = Log4r::INFO unless @global_opts[:debug]

      @log.debug "global options: #{@global_opts.inspect}"
      @log.debug "command: #{@command}; options #{@command_opts.inspect}"
      @log.debug "arguments: #{@arguments.inspect}"

    end

    def run
      if @global_opts[:about]
        puts ABOUT
        exit 0
      end

      @lsi = LSIArray.new(:megacli => @global_opts[:megacli], :fake => @global_opts[:fake])

      begin
        case @command
          when 'show' then run_show
          when 'check' then run_check
        end
      rescue => e
        @log.fatal e.message
        @log.debug e.backtrace
      end
    end

    protected

      def parse_global_options
        @global_opts = Trollop::options @argv do
          banner "MegaCli grokking utility"
          opt :about, "Display #{ME} information"
          opt :debug, "Enable debug mode", :short => "-d"
          opt :fake, "Directory with fake Megacli output", :type => :string
          opt :megacli, "Path to Megacli binary", :type => :string, :default => "Megacli"
          stop_on COMMANDS
        end
      end

      def parse_command
        @command = @argv.shift
        parse_show if @command == 'show'
        parse_check if @command == 'check'
      end

      def parse_arguments
        @arguments = @argv
      end

      def parse_show

      end

      def parse_check
        @command_opts = Trollop::options do
          opt :monitor, "Monitoring system", :type => String, :default => 'nagios'
          opt :mode, "Nagios active|passive check", :type => String, :default => 'active'
          opt :nsca_hostname, "NSCA hostname for passive checks", :type => String, :short => '-H'
          opt :config, "Configuration file", :type => String, :short => 'c'
        end
      end

      def run_show

        raise ArgumentError, "missing component" if @arguments.size == 0
        component = @arguments[0]

        case component
          when 'virtualdrive', 'vd'
            @lsi.virtualdrives.each do |virtualdrive|
              print "#{virtualdrive}\n"
            end
          when 'physicaldrive', 'pd'
            @lsi.physicaldrives.each do |id,physicaldrive|
              print "#{physicaldrive}\n"
            end
          else
            raise ArgumentError, "invalid component #{component}"
          end
      end

      def run_check

        plugin_output = ""
        plugin_status = ""

        @lsi.physicaldrives.each do |id,physicaldrive|
          drive_plugin_string = "[PD:#{physicaldrive._id}:#{physicaldrive[:size]}:#{physicaldrive[:mediatype]}:#{physicaldrive[:pdtype]}]"
          unless physicaldrive[:firmwarestate].state == :online or physicaldrive[:firmwarestate].state == :hotspare
            plugin_output += " #{drive_plugin_string}:#{physicaldrive[:firmwarestate].state}"
            plugin_status = :warning if plugin_status.empty?
          end
          unless physicaldrive[:mediaerrorcount].to_i == 0
            plugin_output += " #{drive_plugin_string}:me:#{physicaldrive[:mediaerrorcount]}"
            plugin_status = :warning if plugin_status.empty?
          end
          unless physicaldrive[:predictivefailurecount].to_i == 0
            plugin_output += " #{drive_plugin_string}:pf:#{physicaldrive[:predictivefailurecount]}"
            plugin_status = :warning if plugin_status.empty?
          end
        end

        plugin_output = "no RAID subsystems errors found" if plugin_output.empty? and plugin_status.empty?
        plugin_status = :ok if plugin_status.empty?

        case @command_opts[:monitor]
          when 'nagios'
            case @command_opts[:mode]
              when 'active'
                puts "#{plugin_status}:#{plugin_output}"
              when 'passive'
                sn = SendNsca.new Socket.gethostname,'raid/lsi'
                sn.nsca_hostname = @command_opts[:nsca_hostname]
                begin
                  sn.send plugin_status , plugin_output
                rescue SendNsca::SendNscaError => e
                  $stderr.write "#{ME}: error: send_nsca failed: #{e.message}\n"
                  exit
                end
            end
        end
      end

  end
end
