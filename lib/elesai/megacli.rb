require 'workflow'
require './lsi'
require './sample_output'
require 'awesome_print'

module Elesai

  class Megacli

    ADAPTER_RE = /^Adapter\s+#*(?<value>\d+)/
    VIRTUALDRIVE_RE = /^Virtual\s+Drive:\s+\d+\s+\((?<key>Target\s+Id):\s+(?<value>\d+)\)/
    SPAN_RE = /^Span:\s+(?<value>\d+)/
    PHYSICALDRIVE_RE = /^(?<key>Enclosure\s+Device\s+ID):\s+(?<value>\d+)/
    EXIT_RE = /^Exit Code: /

    include Workflow

    ### State machine handlers

    # Start

    def on_start_exit(new_state, event, *args)
      puts "    on_#{current_state}_exit: entering #{new_state}"
      new_state.meta = current_state.meta
    end

    # Adapter

    def adapter_line(adapter,key,value)
      puts "event adapter_line: #{adapter}"
      adapter.instance_variable_set("@#{key}".to_sym,value.to_i)
      current_state.meta[:adapter] = adapter
      current_state.meta[:component] = adapter
    end

    def on_adapter_entry(old_state, event, *args)
      puts "      on_#{current_state}_entry: leaving #{old_state}"
    end

    def on_adapter_exit(new_state, event, *args)
      puts "    on_#{current_state}_exit: entering #{new_state}"
      new_state.meta = current_state.meta
    end

    # Virtual Drive

    def virtualdrive_line(virtualdrive,attr,value)
      puts "event: virtualdrive_line"
      current_state.meta[:virtualdrive] = virtualdrive
      current_state.meta[:component] = virtualdrive
    end

    def on_virtualdrive_entry(old_state, event, *args)
      puts "      on_#{current_state}_entry: leaving #{old_state}"
    end

    def on_virtualdrive_exit(new_state, event, *args)
      puts "    on_#{current_state}_exit: entering #{new_state}"
      new_state.meta = current_state.meta
    end

    # Physical Drive

    def physicaldrive_line(physicaldrive,key,value)
      puts "event: physicaldrive_line #{physicaldrive}"
      physicaldrive.instance_variable_set("@#{key}".to_sym,value.to_i)
      current_state.meta[:physicaldrive] = physicaldrive
      current_state.meta[:component] = physicaldrive
    end

    def on_physicaldrive_entry(old_state, event, *args)
      puts "      on_#{current_state}_entry: leaving #{old_state}"
    end

    def on_physicaldrive_exit(new_state, event, *args)
      puts "    on_#{current_state}_exit: entering #{new_state}"
      new_state.meta = current_state.meta
    end

    # Attribute

    def attribute_line(key,value)
      puts "event: attribute_line: #{key} => #{value}"
    end

    def on_attribute_entry(old_state, event, *args)
      puts "      on_#{current_state}_entry: leaving #{old_state}; component: #{current_state.meta[:component]}; args: #{args}"

      component = current_state.meta[:component]
      key = args[0].to_sym
      value = args[1]

      # Some attributes need special treatment so they're actually useful

      case key
        when :coercedsize, :noncoercedsize, :rawsize
          m = /(?<number>[0-9\.]+)\s+(?<unit>[A-Z]+)/.match(value)
          value = LSIArray::PhysicalDrive::Size.new(m[:number],m[:unit])
        when :raidlevel
          m = /Primary-(?<primary>\d+),\s+Secondary-(?<secondary>\d+)/.match(value)
          value = LSIArray::PhysicalDrive::RaidLevel.new(m[:primary],m[:secondary])
        when :firmwarestate
          state,spin = value.gsub(/\s/,'').split(/,/)
          value = LSIArray::PhysicalDrive::FirmwareState.new(state.gsub(/\s/,'_').downcase.to_sym,spin.gsub(/\s/,'_').downcase.to_sym)
        when :mediatype
          value = value.scan(/[A-Z]/).join
        when :inquirydata
          value = value.gsub(/\s+/,' ')
      end
      component[key] = value
    end

    def on_attribute_exit(new_state, event, *args)
      puts "    on_#{current_state}_exit: entering #{new_state}"
    end

    # Exit

    def exit_line
      puts "event: exit_line"
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
      attribute_line!(key.gsub(/\s+/,"").downcase,value)
    end

    # Exit

    def exit_match(match)
      exit_line!
    end

    ### Parse!

    def parse!(output)
      output.each_line do |line|
        line.strip!
        next if line == ''
        puts "#{line}"
        if    line =~ ADAPTER_RE        then adapter_match(ADAPTER_RE.match(line))
        elsif line =~ VIRTUALDRIVE_RE   then virtualdrive_match(VIRTUALDRIVE_RE.match(line))
        elsif line =~ PHYSICALDRIVE_RE  then physicaldrive_match(PHYSICALDRIVE_RE.match(line))
        elsif line =~ EXIT_RE           then exit_match(EXIT_RE.match(line))
        else                                 attribute_match(line)
        end
        puts "***************************************************************************************"
      end
    end

  end

  class PDinfo_aAll < Megacli

    workflow do

      state :start do
        event :exit_line, :transitions_to => :exit_state
        event :adapter_line, :transitions_to => :adapter
      end

      state :adapter do
        event :physicaldrive_line, :transitions_to => :physicaldrive
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
        event :exit_line, :transitions_to => :exit
      end

      state :exit

      on_transition do |from, to, triggering_event, *event_args|
        #puts self.spec.states[to].class
        puts "  transition: #{from} >> #{triggering_event}! >> #{to}: #{event_args.join(' ')}"
        ap current_state.meta[:component]
      end
    end

  end

  megacli = PDinfo_aAll.new.parse! MEGACLI_PDINFO_AALL_OUT

end