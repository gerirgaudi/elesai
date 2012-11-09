require 'workflow'
require 'open3'
require 'io/wait'

module Elesai

  class Megacli

    include Workflow

    ADAPTER_RE = /^Adapter\s+#*(?<value>\d+)/
    VIRTUALDRIVE_RE = /^Virtual\s+Drive:\s+\d+\s+\((?<key>Target\s+Id):\s+(?<value>\d+)\)/
    SPAN_RE = /^Span:\s+(?<value>\d+)/
    PHYSICALDRIVE_RE = /^(?<key>Enclosure\s+Device\s+ID):\s+(?<value>\d+)/
    ATTRIBUTE_RE = /^(?<key>[A-Za-z0-9()\s#'-.&]+)[:|=](?<value>.*)/
    EXIT_RE = /^Exit Code: /

    BBU_RE = /^BBU status for Adapter:\s+(?<value>\d+)/
    BBU_FIRMWARESTATUS_RE = /^BBU Firmware Status:/
    BBU_DESIGNINFO_RE = /^BBU Design Info for Adapter:\s+(?<value>\d+)/
    BBU_PROPERTIES_RE = /^BBU Properties for Adapter:\s+(?<value>\d+)/
    BBU_GASGAUGESTATUS_RE = /^GasGuageStatus:/
    BBU_CAPACITYINFO_RE = /^BBU Capacity Info for Adapter:\s+(?<value>\d+)/


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
          when Elesai::LSIArray::PhysicalDrive
            pd = @lsi.add_physicaldrive(component)
            pd.add_adapter(adapter)
            pd.add_virtualdrive(virtualdrive) unless virtualdrive.nil?
            adapter.add_physicaldrive(pd)
          when Elesai::LSIArray::VirtualDrive
            vd = @lsi.add_virtualdrive(component)
          when Elesai::LSIArray::Adapter
            @lsi.add_adapter(component)
          when Elesai::LSIArray::BBU
            @lsi.add_bbu(component)
        end
        @log.debug "           + context: #{@context[:stack]}"
      end

      def current
        @context[:stack][-1]
      end

      def adapter
        @context[Elesai::LSIArray::Adapter]
      end

      def virtualdrive
        @context[Elesai::LSIArray::VirtualDrive]
      end

      def physicaldrive
        @context[Elesai::LSIArray::PhysicalDrive]
      end

      def bbu
        @context[Elesai::LSIArray::BBU]
      end

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
    end

    def on_adapter_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"

      @context.close unless @context.current.nil? or @context.current === Elesai::LSIArray::Adapter
      @context.open args[0]
    end

    def on_adapter_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # Virtual Drive

    def virtualdrive_line(virtualdrive,key,value)
      @log.debug "  [#{current_state}] event: virtualdrive_line: new #{virtualdrive.inspect}"
      virtualdrive[key.to_sym] = value.to_i
    end

    def on_virtualdrive_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"

      unless @context.current.nil?
        if @context.current === Elesai::LSIArray::VirtualDrive
          @context.close
        end
      end
      virtualdrive = args[0]
      @context.open virtualdrive
    end

    def on_virtualdrive_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # Physical Drive

    def physicaldrive_line(physicaldrive,key,value)
      @log.debug "  [#{current_state}] event: physicaldrive_line: new #{physicaldrive.inspect}"
      physicaldrive[key.to_sym] = value.to_i
    end

    def on_physicaldrive_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.open args[0]
    end

    def on_physicaldrive_exit(new_state, event, *args)
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
          v = LSIArray::PhysicalDrive::Size.new(m[:number],m[:unit])
        when :raidlevel
          m = /Primary-(?<primary>\d+),\s+Secondary-(?<secondary>\d+)/.match(v)
          v = LSIArray::VirtualDrive::RaidLevel.new(m[:primary],m[:secondary])
        when :firmwarestate
          st,sp = v.gsub(/\s/,'').split(/,/)
          state = st.gsub(/\s/,'_').downcase.to_sym
          spin = sp.gsub(/\s/,'_').downcase.to_sym unless sp.nil?
          v = LSIArray::PhysicalDrive::FirmwareState.new(state,spin)
        when :state
          v = v.gsub(/\s/,'_').downcase.to_sym
        when :mediatype
          v = v.scan(/[A-Z]/).join
        when :inquirydata
          v = v.gsub(/\s+/,' ')
        when :relativedtateofcharge, :absolutestateofcharge, :remainingcapacityalarm, :remainingcapacity
          m = /(?<number>[0-9\.]+)\s+(?<unit>[A-Za-z%]+)/.match(v)
          v = LSIArray::BBU::NumberUnit.new(m[:number].to_f,m[:unit])
      end
      c[k] = v
    end

    def on_attribute_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] exit: entering #{new_state} throught event #{event}; args: #{args}"
      @context.close if @context.current.class == Elesai::LSIArray::PhysicalDrive and event != :attribute_line

      @context.flash!(new_state)
    end

    # BBU

    def bbu_line(bbu,key,value)
      @log.debug "  [#{current_state}] event: bbu_line: new #{bbu.inspect}"
      bbu[key.to_sym] = value.to_i
    end

    def on_bbu_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.open args[0]
    end

    def on_bbu_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # BBU Firmware Status

    def bbu_firmwarestatus_line
      @log.debug "  [#{current_state}] event: bbu_firmware_line:"
    end

    def on_bbu_firmwarestatus_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.open @context.current[:firmwarestatus]
    end

    def on_bbu_firmwarestatus_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # BBU DesignInfo Status

    def bbu_designinfo_line
      @log.debug "  [#{current_state}] event: bbu_designinfo_line:"
    end

    def on_bbu_designinfo_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.close
      @context.open @context.current[:designinfo]
    end

    def on_bbu_designinfo_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # BBU Properties Status

    def bbu_properties_line
      @log.debug "  [#{current_state}] event: bbu_designinfo_line:"
    end

    def on_bbu_properties_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.close
      @context.open @context.current[:properties]
    end

    def on_bbu_properties_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # BBU GasGuage Status

    def bbu_gasgaugestatus_line
      @log.debug "  [#{current_state}] event: bbu_gasgaugestatus_line:"
    end

    def on_bbu_gasgaugestatus_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.close
      @context.open @context.current[:gasgaugestatus]
    end

    def on_bbu_gasgaugestatus_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # BBU Capacity Info

    def bbu_capacityinfo_line
      @log.debug "  [#{current_state}] event: bbu_capacityinfo_line:"
    end

    def on_bbu_capacityinfo_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.close
      @context.open @context.current[:capacityinfo]
    end

    def on_bbu_capacityinfo_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
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












    ### Regular Expression Match Handlers

    # Adapter

    def adapter_match(match)
      @log.debug "ADAPTER! #{match.string}"
      key = 'id'
      value = match[:value]
      adapter_line!(LSIArray::Adapter.new,key,value)
    end

    # Virtual Drive

    def virtualdrive_match(match)
      @log.debug "VIRTUALDRIVE! #{match.string}"
      key = match[:key].gsub(/\s+/,"").downcase
      value = match[:value]
      virtualdrive_line!(LSIArray::VirtualDrive.new,key,value)
    end

    # Physical Drive

    def physicaldrive_match(match)
      @log.debug "PHYSICALDRIVE! #{match.string}"
      key = match[:key].gsub(/\s+/,"").downcase
      value = match[:value]
      physicaldrive_line!(LSIArray::PhysicalDrive.new,key,value)
    end

    # Attribute

    def attribute_match(match)
      @log.debug "ATTRIBUTE! #{match.string}"
      key = match[:key].gsub(/\s+/,"").downcase
      value = match[:value].strip
      attribute_line!(key,value)
    end

    # BBU
    def bbu_match(match)
      @log.debug "BBU! #{match.string}"
      key = 'id'
      value = match[:value]
      adapter_line(LSIArray::Adapter.new,key,value)
      bbu_line!(LSIArray::BBU.new,key,value)
    end

    def bbu_firmwarestatus_match(match)
      @log.debug "BBU FIRMWARE! #{match.string}"
      bbu_firmwarestatus_line!
    end

    def bbu_designinfo_match(match)
      @log.debug "BBU DESIGN INFO! #{match.string}"
      bbu_designinfo_line!
    end

    def bbu_properties_match(match)
      @log.debug "BBU PROPERTIES! #{match.string}"
      bbu_properties_line!
    end

    def bbu_capacityinfo_match(match)
      @log.debug "BBU CAPACITY INFO! #{match.string}"
      bbu_capacityinfo_line!
    end

    def bbu_gasgaugestatus_match(match)
      @log.debug "BBU GAS GUAGE STATUS! #{match.string}"
      bbu_gasgaugestatus_line!
    end

    # Exit

    def exit_match(match)
      @log.debug "EXIT! #{match.string}"
      exit_line!
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
        line.strip!
        next if line == ''

        case line
          when ADAPTER_RE              then  adapter_match(ADAPTER_RE.match(line))
          when BBU_RE                  then  bbu_match(BBU_RE.match(line))
          when VIRTUALDRIVE_RE         then  virtualdrive_match(VIRTUALDRIVE_RE.match(line))
          when PHYSICALDRIVE_RE        then  physicaldrive_match(PHYSICALDRIVE_RE.match(line))
          when BBU_FIRMWARESTATUS_RE   then  bbu_firmwarestatus_match(BBU_FIRMWARESTATUS_RE.match(line))
          when BBU_DESIGNINFO_RE       then  bbu_designinfo_match(BBU_DESIGNINFO_RE.match(line))
          when BBU_PROPERTIES_RE       then  bbu_properties_match(BBU_PROPERTIES_RE.match(line))
          when BBU_CAPACITYINFO_RE     then  bbu_capacityinfo_match(BBU_CAPACITYINFO_RE.match(line))
          when BBU_GASGAUGESTATUS_RE   then  bbu_gasgaugestatus_match(BBU_GASGAUGESTATUS_RE.match(line))
          when EXIT_RE                 then  exit_match(EXIT_RE.match(line))
          when ATTRIBUTE_RE            then  attribute_match(ATTRIBUTE_RE.match(line))
          else raise StandardError, "cannot parse '#{line}'"
        end

        @log.debug "\n\n"
      end
    end

  end

  class PDlist_aAll < Megacli

    def parse!(lsi,opts)
      fake = opts[:fake].nil? ? "-pdlist -aall" : File.join(opts[:fake],"pdlist_aall")
      super lsi, :fake => fake, :megacli => opts[:megacli]
    end

    workflow do

      state :start do
        event :adapter_line, :transitions_to => :adapter
        event :exit_line, :transitions_to => :exit
      end

      state :adapter do
        event :adapter_line, :transitions_to => :adapter                 # empty adapter
        event :physicaldrive_line, :transitions_to => :physicaldrive
        event :exit_line, :transitions_to => :exit
      end

      state :physicaldrive do
        event :attribute_line, :transitions_to => :physicaldrive
        event :exit_line, :transitions_to => :exit
        event :adapter_line, :transitions_to => :adapter
        event :physicaldrive_line, :transitions_to => :physicaldrive
        event :attribute_line, :transitions_to => :attribute
      end

      state :attribute do
        event :attribute_line, :transitions_to => :attribute
        event :physicaldrive_line, :transitions_to => :physicaldrive
        event :adapter_line, :transitions_to => :adapter
        event :exit_line, :transitions_to => :exit
      end

      state :exit

      on_transition do |from, to, triggering_event, *event_args|
        #puts self.spec.states[to].class
        # puts "    transition: #{from} >> #{triggering_event}! >> #{to}: #{event_args.join(' ')}"
        #puts "                #{current_state.meta}"
      end
    end

  end

  class LDPDinfo_aAll < Megacli

    def parse!(lsi,opts)
      fake = opts[:fake].nil? ? "-ldpdinfo -aall" : File.join(opts[:fake],"ldpdinfo_aall")
      super lsi, :fake => fake, :megacli => opts[:megacli]
    end


    workflow do

      state :start do
        event :adapter_line, :transitions_to => :adapter
        event :exit_line, :transitions_to => :exit
      end

      state :adapter do
        event :adapter_line, :transitions_to => :adapter
        event :attribute_line, :transitions_to => :attribute
        event :virtualdrive_line, :transitions_to => :virtualdrive
        event :exit_line, :transitions_to => :exit
      end

      state :physicaldrive do
        event :attribute_line, :transitions_to => :physicaldrive
        event :exit_line, :transitions_to => :exit
        event :adapter_line, :transitions_to => :adapter
        event :physicaldrive_line, :transitions_to => :physicaldrive
        event :attribute_line, :transitions_to => :attribute
      end

      state :virtualdrive do
        event :physicaldrive_line, :transitions_to => :physicaldrive
        event :attribute_line, :transitions_to => :attribute
      end

      state :attribute do
        event :attribute_line, :transitions_to => :attribute
        event :virtualdrive_line, :transitions_to => :virtualdrive
        event :physicaldrive_line, :transitions_to => :physicaldrive
        event :adapter_line, :transitions_to => :adapter
        event :exit_line, :transitions_to => :exit
      end

      state :exit

      on_transition do |from, to, triggering_event, *event_args|
        #puts self.spec.states[to].class
        # puts "    transition: #{from} >> #{triggering_event}! >> #{to}: #{event_args.join(' ')}"
        #puts "                #{current_state.meta}"
      end
    end

  end

  class AdpBbuCmd_aAll < Megacli

    def parse!(lsi,opts)
      fake = opts[:fake].nil? ? "-AdpBbuCmd -aAll" : File.join(opts[:fake],"adpbbucmd_aall")
      super lsi, :fake => fake, :megacli => opts[:megacli]
    end

    workflow do

      state :start do
        event :bbu_line, :transitions_to => :bbu
        event :exit_line, :transitions_to => :exit
      end

      state :bbu do
        event :attribute_line, :transitions_to => :attribute
        event :bbu_firmwarestatus_line, :transitions_to => :bbu_firmwarestatus
      end

      state :bbu_firmwarestatus do
        event :attribute_line, :transitions_to => :attribute
      end

      state :bbu_capacityinfo do
        event :attribute_line, :transitions_to => :attribute
      end

      state :bbu_designinfo do
        event :attribute_line, :transitions_to => :attribute
      end

      state :bbu_gasgaugestatus do
        event :attribute_line, :transitions_to => :attribute
      end

      state :bbu_properties do
        event :attribute_line, :transitions_to => :attribute
        event :exit_line, :transitions_to => :exit
      end

      state :attribute do
        event :attribute_line, :transitions_to => :attribute
        event :bbu_firmwarestatus_line, :transitions_to => :bbu_firmwarestatus
        event :bbu_designinfo_line, :transitions_to => :bbu_designinfo
        event :bbu_properties_line, :transitions_to => :bbu_properties
        event :bbu_gasgaugestatus_line, :transitions_to => :bbu_gasgaugestatus
        event :bbu_capacityinfo_line, :transitions_to => :bbu_capacityinfo
        event :exit_line, :transitions_to => :exit
      end

      state :exit
    end

  end


end