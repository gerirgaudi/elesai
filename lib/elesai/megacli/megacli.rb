require 'workflow'
require 'open3'
require 'io/wait'

module Elesai; module Megacli

  class Megacli

    include Workflow

    ### Context

    class Context

      def initialize(current_state,lsi)
        current_state.meta[:context] = { :stack => [] }
        @context = current_state.meta[:context]
        @lsi = lsi
        @log = Elesai::Logger.instance.log
      end

      def open(component)
        @log.debug "         * Open #{component.inspect}"
        @context[:stack].push(component)
        @context[component.class] = component
        @log.debug "           + context: #{@context[:stack]}"
      end

      def flash!(new_state)
        new_state.meta[:context] = @context
        @context = nil
        @context = new_state.meta[:context]
        @log.debug "         + Flash context: #{@context[:stack]}"
      end

      def close
        component = @context[:stack].pop
        @context[component.class] = nil
        @log.debug "         * Close #{component.inspect}"
        case component
          when Elesai::LSI::PhysicalDrive
            pd = @lsi.add_physicaldrive(component)
            pd.add_adapter(adapter)
            pd.add_virtualdrive(virtualdrive) unless virtualdrive.nil?
            adapter.add_physicaldrive(pd)
          when Elesai::LSI::VirtualDrive
            vd = @lsi.add_virtualdrive(component)
          when Elesai::LSI::BBU
            @lsi.add(component)
        end
        @log.debug "           + context: #{@context[:stack]}"
      end

      def current
        @context[:stack][-1]
      end

      def adapter
        @context[Elesai::LSI::Adapter]
      end

      def virtualdrive
        @context[Elesai::LSI::VirtualDrive]
      end

      def physicaldrive
        @context[Elesai::LSI::PhysicalDrive]
      end

      def bbu
        @context[Elesai::LSI::BBU]
      end

    end

    ### Regular Expression Handlers

    # Adapter

    def adapter_match(k,match)
      @log.debug "ADAPTER! #{match.string}"
      key = 'id'
      value = match[:value]
      adapter_line!(LSI::Adapter.new,key,value)
    end

    # Attribute

    def attribute_match(k,match)
      @log.debug "ATTRIBUTE! #{match.string}"
      key = match[:key].gsub(/\s+/,"").downcase
      value_tmp = match[:value]
      value = value_tmp.nil? ? nil : value_tmp.strip
      attribute_line!(key,value)
    end

    # Exit

    def exit_match(k,match)
      @log.debug "EXIT! #{match.string}"
      exit_line!
    end

    ### State Machine Handlers

    # Start

    def on_start_exit(new_state, event, *args)
      @log.debug "      [#{current_state}]: on_exit : #{event} -> #{new_state}; args: #{args}"
      @context = Context.new(current_state,@lsi)
    end

    # Adapter

    def adapter_line(adapter,key,value)
      @log.debug "  [#{current_state}] event adapter_line: new #{adapter.inspect}"
      adapter[key.to_sym] = value.to_i
      @lsi.add(adapter)
    end

    def on_adapter_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"

      @context.close unless @context.current.nil? or Elesai::LSI::Adapter === @context.current
      @context.open args[0]
    end

    def on_adapter_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # Attribute

    def attribute_line(key,value)
      @log.debug "  [#{current_state}] event: attribute_line: #{key} => #{value}"
    end

    def on_attribute_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] entry: leaving #{old_state}; args: #{args}; context: #{@context.current.class}"

      c = @context.current
      k = args[0].to_sym
      v = args[1]

      # Some attributes require special treatment for our purposes

      case k
        when :coercedsize, :noncoercedsize, :rawsize, :size
          m = /(?<number>[0-9\.]+)\s+(?<unit>[A-Z]+)/.match(v)
          v = LSI::PhysicalDrive::Size.new(m[:number],m[:unit])
        when :raidlevel
          m = /Primary-(?<primary>\d+),\s+Secondary-(?<secondary>\d+)/.match(v)
          v = LSI::VirtualDrive::RaidLevel.new(m[:primary],m[:secondary])
        when :firmwarestate
          st,sp = v.gsub(/\s/,'').split(/,/)
          state = st.gsub(/\s/,'_').downcase.to_sym
          spin = sp.gsub(/\s/,'_').downcase.to_sym unless sp.nil?
          v = LSI::PhysicalDrive::FirmwareState.new(state,spin)
        when :state
          v = v.gsub(/\s/,'_').downcase.to_sym
        when :mediatype
          v = v.scan(/[A-Z]/).join
        when :inquirydata
          v = v.gsub(/\s+/,' ')
        when :relativedtateofcharge, :absolutestateofcharge, :remainingcapacityalarm, :remainingcapacity
          m = /(?<number>[0-9\.]+)\s+(?<unit>[A-Za-z%]+)/.match(v)
          v = LSI::BBU::NumberUnit.new(m[:number].to_f,m[:unit])
      end
      c[k] = v
    end

    def on_attribute_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] exit: entering #{new_state} throught event #{event}; args: #{args}"
      @context.close if @context.current.class == Elesai::LSI::PhysicalDrive and event != :attribute_line

      @context.flash!(new_state)
    end

    # Exit

    def exit_line
      @log.debug "  [#{current_state}] event: exit_line"
    end

    def on_exit_entry(new_state, event, *args)
      @log.debug "      [#{current_state}] exit: entering #{new_state} throught event #{event}; args: #{args}"
      until @context.current.nil? do
        @context.close
      end
    end

    ### Parse!

    def parse!(lsi,opts)

      @lsi = lsi
      @log = Elesai::Logger.instance.log
      output = nil

      if STDIN.ready?
        output = $stdin.read
      else
        if opts[:fake].start_with? '-'
          megacli = opts[:megacli].nil? ? "Megacli" : opts[:megacli]
          command = "#{megacli} #{opts[:fake]} -nolog"
          command = Process.uid == 0 ? command : "sudo " << command
          output, stderr_str, status = Open3.capture3(command)
          raise RuntimeError, stderr_str unless status.exitstatus == 0
        else
          output = File.read(opts[:fake])
        end
      end

      output.each_line do |line|
        begin
          line.strip!
          line.gsub!(/^=+$/,'')
          next if line == ''

          match_flag = false
          @megacli.each do |k, v|
            if line =~ v[:re]
              v[:method].call(k,v[:re].match(line))
              match_flag = true
              break
            else
              match_flag = false
              next
            end
          end
          raise StandardError, "cannot parse '#{line}'" unless match_flag
        rescue ArgumentError # ignore lines with invalid byte sequence in UTF-8
          next
        end
      end
    end

  end

end end