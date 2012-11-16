require 'awesome_print'

module Elesai; module Action

  class Check

    DEFAULT_SENEDSA_CONFIG_FILE = File.join(ENV['HOME'],"/.senedsa/config")


    def initialize(arguments,options)
      @options = options.merge!({ :monitor => :nagios, :mode => :active })
      @arguments = []
      @lsi = nil

      opts = OptionParser.new
      opts.banner = "Usage: #{ID} [options] check [check_options]"
      opts.separator ""
      opts.separator "Check Options"
      opts.on('-M', '--monitor [nagios]',            [:nagios],            "Monitoring system")                                 { |o| @options[:monitor]        = monitor }
      opts.on('-m', '--mode [active|passive]',       [:active, :passive],  "Monitoring mode")                                   { |o| @options[:mode]           = mode }
      opts.on('-H', '--nsca_hostname HOSTNAME',      String,               "NSCA hostname to send passive checks")              { |o| @options[:nsca_hostame]   = nsca_hostname }
      opts.on('-c', '--config CONFIG',               String,               "Path to Senedsa (send_nsca) configuration" )        { |o| @options[:senedsa_config] = config }
      opts.on('-S', '--svc_descr SVC_DESR',          String,               "Nagios service description")                        { |o| @options[:svc_descr]      = svc_descr }
      opts.order!

      options_valid?
    end

    def exec

      @lsi = LSIArray.new(:megacli => @options[:megacli], :fake => @options[:fake])

      plugin_output = ""
      plugin_status = ""

      @lsi.physicaldrives.each do |id,physicaldrive|
        drive_plugin_string = "[PD:#{physicaldrive._id}:#{physicaldrive[:size]}:#{physicaldrive[:mediatype]}:#{physicaldrive[:pdtype]}]"
        unless physicaldrive[:firmwarestate].state == :online or physicaldrive[:firmwarestate].state == :hotspare
          plugin_output += " #{drive_plugin_string}:#{physicaldrive[:firmwarestate].state}"
          plugin_status = :critical if physicaldrive[:firmwarestate] == :failed
          plugin_status = :warning if plugin_status.empty?
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

        [:voltage, :temperature, :learncyclestatus].each do |attr|
          unless bbu[:firmwarestatus][attr] == 'OK'
            plugin_output += " [BBU:#{bbu._id}:#{attr}:#{bbu[:firmwarestatus][attr]}]"
            plugin_status = :warning if plugin_status == ""
          end
        end

        [:batterypackmissing, :batteryreplacementrequired].each do |attr|
          unless bbu[:firmwarestatus][attr] == 'No'
            plugin_output += " [BBU:#{attr}:#{bbu[:firmwarestatus][attr]}]"
            plugin_status = :warning if plugin_status == ""
          end
        end

        if bbu[:batterytype] == 'iBBU'
          if bbu[:firmwarestatus][:learncycleactive] == 'Yes'
            plugin_output += " [BBU:absolutestateofcharge:#{bbu[:gasgaugestatus][:absolutestateofcharge]}]"
          else
            if bbu[:firmwarestatus][:chargingstatus] == 'None'
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

      plugin_output = " no LSI RAID errors found" if plugin_output.empty? and plugin_status.empty?
      plugin_status = :ok if plugin_status.empty?

      puts "READY"

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