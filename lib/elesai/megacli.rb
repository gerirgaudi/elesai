require 'workflow'
require 'awesome_print'

module Elesai

  class Megacli

    ADAPTER_RE = /^Adapter\s+#*(?<value>\d+)/
    VIRTUALDRIVE_RE = /^Virtual\s+Drive:\s+\d+\s+\((?<key>Target\s+Id):\s+(?<value>\d+)\)/
    SPAN_RE = /^Span:\s+(?<value>\d+)/
    PHYSICALDRIVE_RE = /^(?<key>Enclosure\s+Device\s+ID):\s+(?<value>\d+)/
    EXIT_RE = /^Exit Code: /

    include Workflow

    ### Helpers

    class Context

      def initialize(current_state,lsi)
        current_state.meta[:context] = []
        @context = current_state.meta[:context]
        @lsi = lsi
      end

      def flash!(new_state)
        new_state.meta[:context] = @context
        @context = nil
        @context = new_state.meta[:context]
        puts "         + Flash context: #@context"
      end

      def open(component)
        puts "         + Push #{component.inspect}"
        @context.push(component)
        puts "         + context: #@context"
      end

      def close
        component = @context.pop
        puts "         + Pop #{component.inspect}"
        puts "         * Closing #{component.inspect}"
        if component.kind_of? LSIArray::PhysicalDrive
          @lsi.add_physicaldrive(component)
        elsif component.kind_of? LSIArray::VirtualDrive
          id = component._id
        elsif component.kind_of? LSIArray::Adapter
          @lsi.add_adapter(component)
        end
        puts "         + context: #@context"
      end

      def current
        @context[-1]
      end

    end

    ### State Machine Handlers

    # Start

    def on_start_exit(new_state, event, *args)
      puts "      [#{current_state}]: on_exit : #{event} -> #{new_state}; args: #{args}"
      @context = Context.new(current_state,@lsi)
    end

    # Adapter

    def adapter_line(adapter,key,value)
      puts "  [#{current_state}] event adapter_line: new #{adapter.inspect}"
      adapter[key.to_sym] = value.to_i
    end

    def on_adapter_entry(old_state, event, *args)
      puts "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"

      @context.close if @context.current.kind_of? LSIArray::Adapter
      adapter = args[0]
      @context.open adapter

    end

    def on_adapter_exit(new_state, event, *args)
      puts "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # Virtual Drive

    def virtualdrive_line(virtualdrive,attr,value)
      puts "  [#{current_state}] event: virtualdrive_line: new #{virtualdrive.inspect}"
    end

    def on_virtualdrive_entry(old_state, event, *args)
      puts "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      virtualdrive = args[0]
      @context.open virtualdrive
    end

    def on_virtualdrive_exit(new_state, event, *args)
      puts "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # Physical Drive

    def physicaldrive_line(physicaldrive,key,value)
      puts "  [#{current_state}] event: physicaldrive_line: new #{physicaldrive.inspect}"
      physicaldrive[key.to_sym] = value.to_i
    end

    def on_physicaldrive_entry(old_state, event, *args)
      puts "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.open args[0]
    end

    def on_physicaldrive_exit(new_state, event, *args)
      puts "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # Attribute

    def attribute_line(key,value)
      puts "  [#{current_state}] event: attribute_line: #{key} => #{value}"
    end

    def on_attribute_entry(old_state, event, *args)
      puts "        [#{current_state}] entry: leaving #{old_state}; args: #{args}"


      c = current_state.meta[:context][-1]
      k = args[0].to_sym
      v = args[1]

      # Some attributes require special treatment for our purposes

      case k
        when :coercedsize, :noncoercedsize, :rawsize
          m = /(?<number>[0-9\.]+)\s+(?<unit>[A-Z]+)/.match(v)
          v = LSIArray::PhysicalDrive::Size.new(m[:number],m[:unit])
        when :raidlevel
          m = /Primary-(?<primary>\d+),\s+Secondary-(?<secondary>\d+)/.match(v)
          v = LSIArray::PhysicalDrive::RaidLevel.new(m[:primary],m[:secondary])
        when :firmwarestate
          state,spin = v.gsub(/\s/,'').split(/,/)
          v = LSIArray::PhysicalDrive::FirmwareState.new(state.gsub(/\s/,'_').downcase.to_sym,spin.gsub(/\s/,'_').downcase.to_sym)
        when :mediatype
          v = v.scan(/[A-Z]/).join
        when :inquirydata
          v = v.gsub(/\s+/,' ')
      end
      c[k] = v
    end

    def on_attribute_exit(new_state, event, *args)
      puts "      [#{current_state}] exit: entering #{new_state} throught event #{event}; args: #{args}"
      @context.close  unless event == :attribute_line

      @context.flash!(new_state)
    end

    # Exit

    def exit_line
      puts "  [#{current_state}] event: exit_line"
    end

    def on_exit_entry(new_state, event, *args)
      puts "      [#{current_state}] exit: entering #{new_state} throught event #{event}; args: #{args}"
      puts "         + context: #{current_state.meta[:context]}"
      @context.close
    end

    ### Regular Expression Match Handlers

    # Adapter

    def adapter_match(match)
      key = 'id'
      value = match[:value]
      adapter_line!(LSIArray::Adapter.new,key,value)
    end

    # Virtual Drive

    def virtualdrive_match(match)
      key = match[:key].gsub(/\s+/,"").downcase
      value = match[:value]
      virtual_driveline!(LSIArray::VirtualDrive.new,key,value)
    end

    # Physical Drive

    def physicaldrive_match(match)
      key = match[:key].gsub(/\s+/,"").downcase
      value = match[:value]
      physicaldrive_line!(LSIArray::PhysicalDrive.new,key,value)
    end

    # Attribute

    def attribute_match(line)
      key,value = line.split(':',2)
      attribute_line!(key.gsub(/\s+/,"").downcase,value.strip)
    end

    # Exit

    def exit_match(match)
      exit_line!
    end

    ### Parse!

    def parse!(lsi,output)

      @lsi = lsi

      output.each_line do |line|
        line.strip!
        next if line == ''

        if    line =~ ADAPTER_RE        then puts "ADAPTER! #{line}";       adapter_match(ADAPTER_RE.match(line))
        elsif line =~ VIRTUALDRIVE_RE   then puts "VIRTUALDRIVE! #{line}";  virtualdrive_match(VIRTUALDRIVE_RE.match(line))
        elsif line =~ PHYSICALDRIVE_RE  then puts "PHYSICALDRIVE! #{line}"; physicaldrive_match(PHYSICALDRIVE_RE.match(line))
        elsif line =~ EXIT_RE           then puts "EXIT! #{line}";          exit_match(EXIT_RE.match(line))
        else                                 puts "ATTRIBUTE! #{line}";     attribute_match(line)
        end

        print "\n\n"
      end
    end

  end

  class PDinfo_aAll < Megacli

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

#  l = LSIArray.new
#  megacli = PDinfo_aAll.new
#  megacli.parse! l, MEGACLI_PDINFO_AALL_OUT

#  ap l.physicaldrives.size

end