module Elesai; module Megacli

  class AdpAllInfo_aAll <  Megacli

    def initialize
      @megacli = { :adapter                     => { :re => /^Adapter\s+#*(?<value>\d+)/,                         :method => self.method(:adapter_match)    },
                   :versions                    => { :re => /^Versions/,                                          :method => self.method(:section_match)    },
                   :mfgdata                     => { :re => /^Mfg\.\s+Data/,                                      :method => self.method(:section_match)    },
                   :imageversions               => { :re => /^Image Versions in Flash/,                           :method => self.method(:section_match)    },
                   :pendingvensions             => { :re => /^Pending Images in Flash/,                           :method => self.method(:section_match)    },
                   :pciinfo                     => { :re => /^PCI Info/,                                          :method => self.method(:section_match)    },
                   :hwconfiguration             => { :re => /^HW Configuration/,                                  :method => self.method(:section_match)    },
                   :setttings                   => { :re => /^Settings/,                                          :method => self.method(:section_match)    },
                   :capabilities                => { :re => /^Capabilities/,                                      :method => self.method(:section_match)    },
                   :status                      => { :re => /^Status/,                                            :method => self.method(:section_match)    },
                   :limitations                 => { :re => /^Limitations/,                                       :method => self.method(:section_match)    },
                   :devicepresent               => { :re => /^Device Present/,                                    :method => self.method(:section_match)    },
                   :supportedadapteroperations  => { :re => /^Supported Adapter Operations/,                      :method => self.method(:section_match)    },
                   :supportedvdoperations       => { :re => /^Supported VD Operations/,                           :method => self.method(:section_match)    },
                   :supportedddoperations       => { :re => /^Supported PD Operations/,                           :method => self.method(:section_match)    },
                   :errorcounters               => { :re => /^Error Counters/,                                    :method => self.method(:section_match)    },
                   :clusterinformation          => { :re => /^ClusterInformation/,                                :method => self.method(:section_match)    },
                   :defaultsettings             => { :re => /^Default Settings/,                                  :method => self.method(:section_match)    },
                   :exit                        => { :re => /^Exit Code: /,                                       :method => self.method(:exit_match)       },
                   :attribute                   => { :re => /^(?<key>[A-Za-z0-9()\s#'-.&]+)([:|=](?<value>.*))?/, :method => self.method(:attribute_match)  }
      }.freeze
      @command_arguments = "-adpallinfo -aall".freeze
      @command_output_file = "adpallinfo_aall".freeze
    end

    def parse!(lsi,opts)
      fake = opts[:fake].nil? ? @command_arguments : File.join(opts[:fake],@command_output_file)
      super lsi, :fake => fake, :megacli => opts[:megacli]
    end

    # State Machine

    workflow do

      state :start do
        event :adapter_line, :transitions_to => :adapter
        event :exit_line, :transitions_to => :exit
      end

      state :adapter do
        event :adapter_line, :transitions_to => :adapter                 # empty adapter
        event :section_line, :transitions_to => :section
        event :exit_line, :transitions_to => :exit
      end

      state :section do
        event :exit_line, :transitions_to => :exit
        event :adapter_line, :transitions_to => :adapter
        event :attribute_line, :transitions_to => :attribute
      end

      state :attribute do
        event :attribute_line, :transitions_to => :attribute
        event :section_line, :transitions_to => :section
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

    ### Match Handlers

    def section_match(k,match)
      @log.debug "ADPINFO_SECTION! #{k} -> #{match.string}"
      section_line!(LSI::Adapter::Section.new(k))
    end

    ### Line Handlers

    def section_line(section)
      @log.debug "  [#{current_state}] event: section_line: new #{section.inspect}"
    end

    def on_section_entry(old_state, event, *args)
      @log.debug "     [#{current_state}] on_entry: leaving #{old_state}; args: #{args}"
      unless @context.current.nil?
        @context.close if Elesai::LSI::Adapter::Section === @context.current
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