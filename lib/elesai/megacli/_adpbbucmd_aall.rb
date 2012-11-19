module Elesai; module Megacli

  class AdpBbuCmd_aAll < Megacli

    def initialize
      @megacli = {  :bbu            => { :re => /^BBU status for Adapter:\s+(?<value>\d+)/,         :method => self.method(:bbu_match)            },
                    :firmwarestatus => { :re => /^BBU Firmware Status:/,                            :method => self.method(:firmwarestatus_match) },
                    :designinfo     => { :re => /^BBU Design Info for Adapter:\s+(?<value>\d+)/,    :method => self.method(:designinfo_match)     },
                    :properties     => { :re => /^BBU Properties for Adapter:\s+(?<value>\d+)/,     :method => self.method(:properties_match)     },
                    :gasgaugestatus => { :re => /^GasGuageStatus:/,                                 :method => self.method(:gasgaugestatus_match) },
                    :capacityinfo   => { :re => /^BBU Capacity Info for Adapter:\s+(?<value>\d+)/,  :method => self.method(:capacityinfo_match)   },
                    :exit           => { :re => /^Exit Code: /,                                     :method => self.method(:exit_match)           },
                    :attribute      => { :re => /^(?<key>[A-Za-z0-9()\s#'-.&]+)[:|=](?<value>.*)/,  :method => self.method(:attribute_match)      }
      }.freeze
      @command_arguments = "-adpbbucmd -aall".freeze
      @command_output_file = "adpbbucmd_aall".freeze
    end

    def parse!(lsi,opts)
      fake = opts[:fake].nil? ? "-AdpBbuCmd -aAll" : File.join(opts[:fake],"adpbbucmd_aall")
      super lsi, :fake => fake, :megacli => opts[:megacli]
    end

    # State Machine

    workflow do

      state :start do
        event :bbu_line,            :transitions_to => :bbu
        event :exit_line,           :transitions_to => :exit
      end

      state :bbu do
        event :attribute_line,      :transitions_to => :attribute
        event :firmwarestatus_line, :transitions_to => :firmwarestatus
      end

      state :firmwarestatus do
        event :attribute_line,      :transitions_to => :attribute
      end

      state :capacityinfo do
        event :attribute_line,      :transitions_to => :attribute
      end

      state :designinfo do
        event :attribute_line,      :transitions_to => :attribute
      end

      state :gasgaugestatus do
        event :attribute_line,      :transitions_to => :attribute
      end

      state :properties do
        event :attribute_line,      :transitions_to => :attribute
        event :exit_line,           :transitions_to => :exit
      end

      state :attribute do
        event :attribute_line,      :transitions_to => :attribute
        event :firmwarestatus_line, :transitions_to => :firmwarestatus
        event :designinfo_line,     :transitions_to => :designinfo
        event :properties_line,     :transitions_to => :properties
        event :gasgaugestatus_line, :transitions_to => :gasgaugestatus
        event :capacityinfo_line,   :transitions_to => :capacityinfo
        event :exit_line,           :transitions_to => :exit
      end

      state :exit

    end

    # Regular Expression Match Handlers

    def bbu_match(k,match)
      @log.debug "BBU! #{match.string}"
      key = 'id'
      value = match[:value]
      adapter_line(LSI::Adapter.new,key,value)
      bbu_line!(LSI::BBU.new,key,value)
    end

    def firmwarestatus_match(k,match)
      @log.debug "BBU FIRMWARE! #{match.string}"
      firmwarestatus_line!
    end

    def designinfo_match(k,match)
      @log.debug "BBU DESIGN INFO! #{match.string}"
      designinfo_line!
    end

    def properties_match(k,match)
      @log.debug "BBU PROPERTIES! #{match.string}"
      properties_line!
    end

    def capacityinfo_match(k,match)
      @log.debug "BBU CAPACITY INFO! #{match.string}"
      capacityinfo_line!
    end

    def gasgaugestatus_match(k,match)
      @log.debug "BBU GAS GUAGE STATUS! #{match.string}"
      gasgaugestatus_line!
    end

    ### Line Handlers

    #   BBU

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

    #   BBU Firmware Status

    def firmwarestatus_line
      @log.debug "  [#{current_state}] event: bbu_firmware_line:"
    end

    def on_firmwarestatus_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.open @context.current[:firmwarestatus]
    end

    def on_firmwarestatus_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    #   BBU DesignInfo Status

    def designinfo_line
      @log.debug "  [#{current_state}] event: bbu_designinfo_line:"
    end

    def on_designinfo_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.close
      @context.open @context.current[:designinfo]
    end

    def on_designinfo_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    #   BBU Properties Status

    def bbu_properties_line
      @log.debug "  [#{current_state}] event: bbu_designinfo_line:"
    end

    def on_properties_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.close
      @context.open @context.current[:properties]
    end

    def on_properties_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # BBU GasGuage Status

    def gasgaugestatus_line
      @log.debug "  [#{current_state}] event: bbu_gasgaugestatus_line:"
    end

    def on_gasgaugestatus_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.close
      @context.open @context.current[:gasgaugestatus]
    end

    def on_gasgaugestatus_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

    # BBU Capacity Info

    def capacityinfo_line
      @log.debug "  [#{current_state}] event: bbu_capacityinfo_line:"
    end

    def on_capacityinfo_entry(old_state, event, *args)
      @log.debug "        [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      @context.close
      @context.open @context.current[:capacityinfo]
    end

    def on_capacityinfo_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

  end

end end


