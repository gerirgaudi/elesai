module Elesai; module Megacli

  class LDPDinfo_aAll < Megacli

    def initialize
      @megacli = { :adapter       => { :re => /^Adapter\s+#*(?<value>\d+)/,                                         :method => self.method(:adapter_match) },
                   :virtualdrive  => { :re => /^Virtual\s+Drive:\s+\d+\s+\((?<key>Target\s+Id):\s+(?<value>\d+)\)/, :method => self.method(:virtualdrive_match) },
                   :physicaldrive => { :re => /^(?<key>Enclosure\s+Device\s+ID):\s+(?<value>\d+)/,                  :method => self.method(:physicaldrive_match) },
                   :exit          => { :re => /^Exit Code: /,                                                       :method => self.method(:exit_match) },
                   :attribute     => { :re => /^(?<key>[A-Za-z0-9()\s#'-.&]+)[:|=](?<value>.*)/,                    :method => self.method(:attribute_match) }
      }.freeze

      @match = nil
      @command_arguments = "-pdldinfo -aall"
      @command_output_file = "ldpdinfo_aall"
    end

    def parse!(lsi,opts)
      fake = opts[:fake].nil? ? "-ldpdinfo -aall" : File.join(opts[:fake],"ldpdinfo_aall")
      super lsi, :fake => fake, :megacli => opts[:megacli]
    end

    # Regular Expression Match Handlers

    def virtualdrive_match(match)
      @log.debug "VIRTUALDRIVE! #{match.string}"
      key = match[:key].gsub(/\s+/,"").downcase
      value = match[:value]
      virtualdrive_line!(LSIArray::VirtualDrive.new,key,value)
    end

    def physicaldrive_match(match)
      @log.debug "PHYSICALDRIVE! #{match.string}"
      key = match[:key].gsub(/\s+/,"").downcase
      value = match[:value]
      physicaldrive_line!(LSIArray::PhysicalDrive.new,key,value)
    end

    # Line Handlers

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
end; end
