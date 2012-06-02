require 'rubygems'
require 'statemachine'

module Elesai

  module MegaCli

    class Context

      attr_accessor :lsiarray, :current_adapter, :current_virtualdrive, :current_physicaldrive, :statemachine

      class Error < StandardError; end
      class ConfigurationError < Error; end

      def initialize
        @lsiarray = nil
        @current_adapter = nil
        @current_virtualdrive = nil
        @current_physicaldrive = nil
      end

      def create_adapter(id)
        @current_adapter = @lsiarray.create_adapter(id)
      end

      def add_adapter
        @lsiarray.add_adapter(@current_adapter)
      end

      def create_virtualdrive(id)
        @current_virtualdrive = @lsiarray.create_virtualdrive(id)
      end

      def process_virtualdrive
        @lsiarray.add_virtualdrive(@current_virtualdrive)
        @current_adapter.virtualdrives.push(@current_virtualdrive)
      end

      def create_physicaldrive(attribute=nil,value=nil)
        @current_physicaldrive = @lsiarray.create_physicaldrive
        case attribute
          when :enclosure
            @current_physicaldrive.enclosure = value
          when :id
            @current_physicaldrive.id = value
        end
      end

      def process_physicaldrive
        id = @current_physicaldrive.id

        @current_physicaldrive = @lsiarray.physicaldrives[id] if @lsiarray.physicaldrives[id]
        @lsiarray.add_physicaldrive(@current_physicaldrive)

        @current_physicaldrive.virtualdrives.push(@current_virtualdrive)
        @current_virtualdrive.physicaldrives[id] = @current_physicaldrive unless @current_virtualdrive.nil?
        @current_adapter.physicaldrives.push(@current_physicaldrive)
      end

      def add_attribute(rawkey,rawvalue)
        rawkey.strip!
        rawvalue.strip!
        key = rawkey.gsub(/\s/,'').downcase.to_sym
        value = rawvalue.strip

        case @statemachine.state
          when :adapter_found, :adapter_created
            @current_adapter.rawattributes[key] = value
          when :virtualdrive_found, :virtualdrive_created
            if rawkey =~ /^RAID Level/
              /Primary-(\d+),\s+Secondary-(\d+)/.match(value)
              @current_virtualdrive.raidlevel = [$1,$2]
            end
            @current_virtualdrive.size = value.split(/\s/)[0] if rawkey =~ /^Size$/
            @current_virtualdrive.state = value if rawkey =~ /State/
          when :physicaldrive_found, :physicaldrive_created
            if rawkey =~ /Device Id/
              @current_physicaldrive.deviceid = value.to_i
            elsif rawkey =~ /Coerced Size/
              /([0-9\.]+)\s+([A-Z]+)/.match(value)
              @current_physicaldrive.size = [$1,$2]
            elsif rawkey =~ /Firmware state/
              state,spin = value.gsub(/\s/,'').split(/,/)
              @current_physicaldrive.state = state.gsub(/\s/,'_').downcase.to_sym
              @current_physicaldrive.spin = spin.gsub(/\s/,'_').downcase.to_sym
            elsif rawkey =~ /^PD Type/
              @current_physicaldrive.pdtype = value
            elsif rawkey =~ /Media Type/
              @current_physicaldrive.mediatype = value.scan(/[A-Z]/).join
            elsif rawkey =~ /Inquiry Data/
              @current_physicaldrive.inquirydata = value.gsub(/\s+/,' ')
            end
            @current_physicaldrive.slot = value.to_i if rawkey =~ /Slot Number/
            @current_physicaldrive.mediaerrors = value.to_i if rawkey =~ /Media Error Count/
            @current_physicaldrive.predictivefailure = value.to_i if rawkey =~ /Predictive Failure Count/
            @current_physicaldrive.enclosure = value.to_i if rawkey =~ /Enclosure Device ID/
          else
            raise Statemachine::StatemachineException, "invalid state machine state #{@statemachine.state}"
        end
      end

      def process_exit
      end

    end

    class Command

      attr_reader :statemachine, :regexes, :lsiarray

      def initialize(cmdsig,lsiarray)
        @cmdsig = cmdsig
        @lsiarray = lsiarray
        @statemachine = nil
        @regexes = {}
        case cmdsig
          when :megacli_pdinfo_aall
            @statemachine = Statemachine.build do
              state :start do
                event :exitline, :exit, :process_exit
                event :adapterline, :adapter_found
              end
              state :adapter_found do
                on_entry :create_adapter
                event :physicaldriveline, :physicaldrive_found
                on_exit :add_adapter
              end
              state :physicaldrive_found do
                on_entry :create_physicaldrive
                event :line, :physicaldrive_created, :add_attribute
              end
              state :physicaldrive_created do
                event :exitline, :exit, :process_exit
                event :adapterline, :adapter
                event :physicaldriveline, :physicaldrive_found
                event :line, :physicaldrive_created, :add_attribute
                on_exit :process_physicaldrive
              end
              context Context.new
            end
            @statemachine.context.statemachine = @statemachine
            @statemachine.context.lsiarray = @lsiarray
            @regexes = {
              :adapter        => /^Adapter\s+#*(\d+)/,
              :virtualdrive   => /^Virtual\s+Drive:\s+(\d+)/,
              :physicaldrive  => /^Enclosure Device ID:\s+(\d+)/,
              :exit           => /^Exit Code: /
            }
            @output = MEGACLI_PDINFO_AALL_OUT
          when :megacli_ldpdinfo_aall
            @statemachine = Statemachine.build do
              state :start do
                event :exitline, :exit, :process_exit
                event :adapterline, :adapter_found
              end
              state :adapter_found do
                on_entry :create_adapter
                event :line, :adapter_created, :add_attribute
              end
              state :adapter_created do
                event :virtualdriveline, :virtualdrive_found
                event :line, :adapter_created, :add_attribute
                on_exit :add_adapter
              end
              state :virtualdrive_found do
                on_entry :create_virtualdrive
                event :line, :virtualdrive_created, :add_attribute
              end
              state :virtualdrive_created do
                event :exitline, :exit, :process_exit
                event :adapterline, :adapter_found
                event :virtualdriveline, :virtualdrive_found
                event :physicaldriveline, :physicaldrive_found
                event :line, :virtualdrive_created, :add_attribute
                on_exit :process_virtualdrive
              end
              state :physicaldrive_found do
                on_entry :create_physicaldrive
                event :line, :physicaldrive_created, :add_attribute
              end
              state :physicaldrive_created do
                event :exitline, :exit, :process_exit
                event :adapterline, :adapter
                event :virtualdriveline, :virtualdrive_found
                event :physicaldriveline, :physicaldrive_found
                event :line, :physicaldrive_created, :add_attribute
                on_exit :process_physicaldrive
              end
              context Context.new
            end
            @statemachine.context.statemachine = @statemachine
            @statemachine.context.lsiarray = @lsiarray
            @regexes = {
              :adapter        => /^Adapter\s+#*(\d+)/,
              :virtualdrive   => /^Virtual\s+Drive:\s+(\d+)/,
              :physicaldrive  => /^PD:\s+(\d+)\s+Information/,
              :exit           => /^Exit Code: /
            }
            @output = MEGACLI_LDPDINFO_AALL_OUT
          else
            raise Exception, "invalid megacli signature"
        end
      end

      def run
        @output.each_line do |line|
          line.strip!
          next if line == ''
          if @regexes[:adapter].match(line)
            @statemachine.adapterline($1.to_i)
          elsif @regexes[:virtualdrive].match(line)
            @statemachine.virtualdriveline($1.to_i)
          elsif @regexes[:physicaldrive].match(line)
            case @cmdsig
              when :megacli_pdinfo_aall
                @statemachine.physicaldriveline(:enclosure,$1.to_i)
              when :megacli_ldpdinfo_aall
                @statemachine.physicaldriveline(:id,$1.to_i)
            end
          elsif @regexes[:exit].match(line)
            @statemachine.exitline
          else
            key,value = line.split(':',2)
            @statemachine.line(key.to_s,value.to_s)
          end
        end
      end
    end
  end
end