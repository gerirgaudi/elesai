module Elesai; module Megacli

  class AdpBbuCmd_aAll < Megacli

    def initialize
      @megacli = {  :bbu            => { :re => /^BBU status for Adapter:\s+(?<value>\d+)/,         :method => self.method(:bbu_match)       },
                    :firmwarestatus => { :re => /^BBU Firmware Status:/,                            :method => self.method(:section_match)   },
                    :designinfo     => { :re => /^BBU Design Info for Adapter:\s+(?<value>\d+)/,    :method => self.method(:section_match)   },
                    :properties     => { :re => /^BBU Properties for Adapter:\s+(?<value>\d+)/,     :method => self.method(:section_match)   },
                    :gasgaugestatus => { :re => /^GasGuageStatus:/,                                 :method => self.method(:section_match)   },
                    :capacityinfo   => { :re => /^BBU Capacity Info for Adapter:\s+(?<value>\d+)/,  :method => self.method(:section_match)   },
                    :exit           => { :re => /^Exit Code: /,                                     :method => self.method(:exit_match)      },
                    :attribute      => { :re => /^(?<key>[A-Za-z0-9()\s#'-.&]+)[:|=](?<value>.*)/,  :method => self.method(:attribute_match) }
      }.freeze
      @command_arguments = "-adpbbucmd -aall".freeze
      @command_output_file = "adpbbucmd_aall".freeze
    end

    def parse!(lsi,opts)
      fake = opts[:fake].nil? ? @command_argument : File.join(opts[:fake],@command_output_file)
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
        event :section_line,        :transitions_to => :section
      end

      state :section do
        event :exit_line, :transitions_to => :exit
        event :attribute_line, :transitions_to => :attribute
      end

      state :attribute do
        event :attribute_line,      :transitions_to => :attribute
        event :section_line,        :transitions_to => :section
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

    def section_match(k,match)
      @log.debug "ADPINFO_SECTION! #{k} -> #{match.string}"
      section_line!(LSI::BBU::Section.new(k))
    end

    ### Line Handlers

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

    def section_line(section)
      @log.debug "  [#{current_state}] event: section_line: new #{section.inspect}"
    end

    def on_section_entry(old_state, event, *args)
      @log.debug "     [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      unless @context.current.nil?
        @context.close if Elesai::LSI::BBU::Section === @context.current
      end
      @context.current.add_section(args[0])
      @context.open(args[0])
    end

    def on_section_exit(new_state, event, *args)
      @log.debug "      [#{current_state}] on_exit: entering #{new_state}; args: #{args}"
      @context.flash!(new_state)
    end

  end

end end


