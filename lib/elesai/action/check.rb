require 'senedsa'

module Elesai; module Action

  class Check

    DEFAULT_SENEDSA_CONFIG_FILE = File.join(ENV['HOME'],"/.senedsa/config")

    include Senedsa

    def initialize(arguments,options)
      @options = options.merge!({ :monitor => :nagios, :mode => :active })
      @arguments = []
      @lsi = nil

      opts = OptionParser.new
      opts.banner = "Usage: #{ID} [options] check [check_options]"
      opts.separator ""
      opts.separator "Check Options"
      opts.on('-M', '--monitor [nagios]',            [:nagios],            "Monitoring system")                                 { |o| @options[:monitor]        = o }
      opts.on('-m', '--mode [active|passive]',       [:active, :passive],  "Monitoring mode")                                   { |o| @options[:mode]           = o }
      opts.on('-H', '--nsca_hostname HOSTNAME',      String,               "NSCA hostname to send passive checks")              { |o| @options[:nsca_hostame]   = o }
      opts.on('-c', '--config CONFIG',               String,               "Path to Senedsa (send_nsca) configuration" )        { |o| @options[:senedsa_config] = o }
      opts.on('-S', '--svc_descr SVC_DESR',          String,               "Nagios service description")                        { |o| @options[:svc_descr]      = o }
      opts.order!(arguments)

      options_valid?
    end

    def exec

      @lsi = LSI.new(:megacli => @options[:megacli], :fake => @options[:fake])

      plugin_output = ""
      plugin_status = ""

      @lsi.physicaldrives.each do |id,physicaldrive|
        drive_plugin_string = "[PD:#{physicaldrive._id}:#{physicaldrive[:size]}:#{physicaldrive[:mediatype]}:#{physicaldrive[:pdtype]}]"
        unless physicaldrive[:firmwarestate].state == :online or physicaldrive[:firmwarestate].state == :hotspare
          plugin_output += " #{drive_plugin_string}:#{physicaldrive[:firmwarestate].state}"
          plugin_status = :critical if physicaldrive[:firmwarestate] == :failed
          plugin_status = :warning if  physicaldrive[:firmwarestate] == :rebuild and plugin_status != :critical
        end
        unless physicaldrive[:mediaerrorcount].to_i < 10
          plugin_output += " #{drive_plugin_string}:MediaError:#{physicaldrive[:mediaerrorcount]}"
          plugin_status = :warning if plugin_status.empty?
        end
        unless physicaldrive[:predictivefailurecount].to_i < 5
          plugin_output += " #{drive_plugin_string}:PredictiveFailure:#{physicaldrive[:predictivefailurecount]}"
          plugin_status = :warning if plugin_status.empty?
        end
      end

      @lsi.virtualdrives.each do |vd|
        vd_plugin_string = "[VD:#{vd._id}]"
        unless vd[:state] == :optimal
          plugin_output += " #{vd_plugin_string}:#{vd[:state]}"
          plugin_status = :critical
        end
      end

      @lsi.bbus.each do |bbu|

        unless bbu[:firmwarestatus][:temperature] == 'OK'
          plugin_output += " [BBU:#{bbu._id}:temperature:#{bbu[:firmwarestatus][:temperature]}:#{bbu[:temperature].gsub(/\s/,'')}]"
        end

        unless bbu[:firmwarestatus][:learncyclestatus] == 'OK'
          plugin_output += " [BBU:#{bbu._id}:learncyclestatus:#{bbu[:firmwarestatus][:learncyclestatus]}]"
          plugin_status = :warning if plugin_status == ""
        end

        [:batterypackmissing, :batteryreplacementrequired].each do |attr|
          unless bbu[:firmwarestatus][attr] == 'No'
            plugin_output += " [BBU:#{attr}:#{bbu[:firmwarestatus][attr]}]"
            plugin_status = :warning if plugin_status == ""
          end
        end

        if bbu[:batterytype] == 'iBBU'
          if bbu[:firmwarestatus][:learncycleactive] == 'Yes'
            plugin_output += " learn cycle enabled: [BBU:absolutestateofcharge:#{bbu[:gasgaugestatus][:absolutestateofcharge]}]"
          else
            unless bbu[:firmwarestatus][:voltage] == 'OK'
              plugin_output += " [BBU:#{bbu._id}:voltage:#{bbu[:firmwarestatus][:voltage]}]"
              plugin_status = :warning if plugin_status == ""
            end
            if bbu[:firmwarestatus][:chargingstatus] == 'None' or bbu[:gasgaugestatus][:discharging] == 'No'
              if bbu[:gasgaugestatus][:absolutestateofcharge].number <= 65
                plugin_output += " [BBU:absolutestateofcharge:#{bbu[:gasgaugestatus][:absolutestateofcharge]}]"
                plugin_status = :warning if plugin_status == ""
              end
              if bbu[:capacityinfo][:remainingcapacity].number <= bbu[:capacityinfo][:remainingcapacityalarm].number
                plugin_output += " [BBU:remainingcapacity:#{bbu[:capacityinfo][:remainingcapacityalarm]}]"
                plugin_status = :warning if plugin_status == ""
              end
            end
          end
        end
      end

      if plugin_output.empty? and plugin_status.empty?
        @lsi.adapters.each do |adapter|
          plugin_output += " [#{adapter._id}: #{adapter[:versions][:productname].gsub(/\s+/,'_')} OK]"
        end
      end
      plugin_status = :ok if plugin_status.empty?

      case @options[:monitor]
        when :nagios
          case @options[:mode]
            when :active
              puts "#{plugin_status.to_s.upcase}:#{plugin_output}"
              exit SendNsca::STATUS[plugin_status]
            when :passive
              sn = SendNsca.new @options
              begin
                sn.send plugin_status , plugin_output
              rescue SendNsca::SendNscaError => e
                raise RuntimeError, "send_nsca failed: #{e.message}"
              end
          end
      end
    end


    protected

    def options_valid?
      raise OptionParser::MissingArgument, "NSCA hostname (-H) must be specified"       if @options[:nsca_hostname].nil?  and @options[:mode] == 'passive'
      raise OptionParser::MissingArgument, "service description (-S) must be specified" if @options[:svc_descr].nil?      and @options[:mode] == 'passive'
    end

    def config_options?
      cfg_file = nil
      cfg_file = @options[:senedsa_config] unless @options[:senedsa_config].nil?
      cfg_file = DEFAULT_SENEDSA_CONFIG_FILE if @options[:senedsa_config].nil? and File.readable? DEFAULT_SENEDSA_CONFIG_FILE

      unless cfg_file.nil?
        @options.merge!(Senedsa::SendNsca.configure(cfg_file))
        @options[:senedsa_config] = cfg_file
      end
    end


  end

end end