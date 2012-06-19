require 'optparse'
require 'senedsa'
include Senedsa
require 'elesai/version'
require 'elesai/about'

module Elesai

  class CLI

    COMMANDS = %w(show check)
    COMPONENTS = %w(virtualdrive vd physicaldrive pd)
    DEFAULT_CONFIG_FILE = File.join(ENV['HOME'],"/.senedsa/config")

    def initialize(arguments)
      @arguments = arguments

      @global_options = { :debug => false, :megacli => 'MegaCli' }
      @action_options = { :monitor => 'nagios', :mode => 'active' }
      @action = nil
    end

    def run
      begin
        parsed_options?

        @log = Elesai::Logger.instance.log
        @log.level = Log4r::INFO unless @global_options[:debug]

        config_options?
        arguments_valid?
        options_valid?
        process_options
        process_arguments
        process_command

      rescue => e #ArgumentError, OptionParser::MissingArgument, Senedsa::SendNsca::ConfigurationError => e
        output_message e.message, 1
      end
    end

    protected

      def parsed_options?
        opts = OptionParser.new

        opts.banner = "Usage: #{ID} [options] <action> [options]"
        opts.separator ""
        opts.separator "Actions:"
        opts.separator "    show                             Displays component information"
        opts.separator "    check                            Performs health checks"
        opts.separator ""
        opts.separator "General options:"
        opts.on('-m', '--megacli MEGACLI',                String,              "Path to MegaCli binary")                             { |megacli| @global_options[:megacli] = megacli }
        opts.on('-f', '--fake DIRECTORY',                 String,              "Path to directory with Megacli output")              { |dir| @global_options[:fake] = dir }
        opts.on('-d', '--debug',                                               "Enable debug mode")                                  { @global_options[:debug] = true}
        opts.on('-a', '--about',                                               "Display #{ID} information")                          { output_message ABOUT, 0 }
        opts.on('-V', '--version',                                             "Display #{ID} version")                              { output_message VERSION, 0 }
        opts.on_tail('--help',                                                 "Show this message")                                  { @global_options[:HELP] = true }

        actions = {
            :show => OptionParser.new do |aopts|
                aopts.banner = "Usage: #{ID} [options] show <component>"
                aopts.separator ""
                aopts.separator "      <component> is physicaldisk|pd, virtualdisk|vd"
              end,
            :check => OptionParser.new do |aopts|
                aopts.banner = "Usage: #{ID} [options] check [check_options]"
                aopts.separator ""
                aopts.separator "Check Options"
                aopts.on('-M', '--monitor [nagios]',            [:nagios],            "Monitoring system")                                 { |monitor| @action_options[:monitor] = monitor }
                aopts.on('-m', '--mode [active|passive]',       [:active, :passive],  "Monitoring mode")                                   { |mode| @action_options[:mode] = mode }
                aopts.on('-H', '--nsca_hostname HOSTNAME',      String,               "NSCA hostname to send passive checks")              { |nsca_hostname| @action_options[:nsca_hostame] = nsca_hostname }
                aopts.on('-c', '--config CONFIG',               String,               "Path to Senedsa (send_nsca) configuration" )        { |config| @action_options[:senedsa_config] = config }
                aopts.on('-S', '--svc_descr SVC_DESR',          String,               "Nagios service description")                        { |svc_descr| @action_options[:svc_descr] = svc_descr }
              end
            }

        opts.order!
        output_message opts, 0 if @arguments.size == 0 or @global_options[:HELP]

        @action = ARGV.shift.to_sym
        raise OptionParser::InvalidArgument, "invalid action #@action" if actions[@action].nil?
        actions[@action].order!
      end

      def config_options?
        cfg_file = nil
        cfg_file = @action_options[:senedsa_config] unless @action_options[:senedsa_config].nil?
        cfg_file = DEFAULT_CONFIG_FILE if @action_options[:senedsa_config].nil? and File.readable? DEFAULT_CONFIG_FILE

        unless cfg_file.nil?
          @action_options.merge!(Senedsa::SendNsca.configure(cfg_file))
          @action_options[:senedsa_config] = cfg_file
        end
      end

      def arguments_valid?
        true
      end

      def options_valid?
        case @action
          when :check
            raise OptionParser::MissingArgument, "NSCA hostname (-H) must be specified" if @action_options[:nsca_hostname].nil? and @action_options[:mode] == 'passive'
            raise OptionParser::MissingArgument, "service description (-S) must be specified" if @action_options[:svc_descr].nil? and @action_options[:mode] == 'passive'
        end
      end

      def process_options
        true
      end

      def process_arguments
        @action_options[:hint] = @arguments[0].nil? ? nil : @arguments[0].to_sym
        true
      end

      def process_command

        @lsi = LSIArray.new(:megacli => @global_options[:megacli], :fake => @global_options[:fake], :hint => @action_options[:hint])

        case @action
          when :show then run_show
          when :check then run_check
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

        plugin_output = "no LSI RAID errors found" if plugin_output.empty? and plugin_status.empty?
        plugin_status = :ok if plugin_status.empty?

        case @action_options[:monitor]
          when 'nagios'
            case @action_options[:mode]
              when 'active'
                puts "#{plugin_status}: #{plugin_output}"
                exit SendNsca::STATUS[plugin_status]
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

      def output_message(message, exitstatus=nil)
        m = (! exitstatus.nil? and exitstatus > 0) ? "%s: error: %s" % [ID, message] : message
        $stderr.write "#{m}\n"
        exit exitstatus unless exitstatus.nil?
      end

  end
end





