require 'ostruct'

module Elesai

  class LSIArray

    attr_reader :adapters, :virtualdrives, :physicaldrives, :enclosures

    def initialize
      @adapters = []
      @virtualdrives = []
      @physicaldrives = {}
      @enclosures = []
      megacli = MegaCli::Command.new(:megacli_pdinfo_aall,self)
      megacli.run
      megacli = MegaCli::Command.new(:megacli_ldpdinfo_aall,self)
      megacli.run
    end

    def create_adapter(id)
      Adapter.new(id)
    end

    def add_adapter(adapter)
      @adapters[adapter.id] = adapter
    end

    def create_virtualdrive(id)
      VirtualDrive.new(id)
    end

    def add_virtualdrive(virtualdrive)
      @virtualdrives.push(virtualdrive)
    end

    def create_physicaldrive
      PhysicalDrive.new
    end

    def add_physicaldrive(physicaldrive)
      @physicaldrives[physicaldrive.id] = physicaldrive
    end

    def to_s
      lsiarrayout = "LSI Array\n"
      @adapters.each do |adapter|
        lsiarrayout += "  adapter #{adapter.id}\n"
        adapter.virtualdrives.each do |virtualdrive|
          lsiarrayout += "    +--+ #{virtualdrive.to_str}\n"
          virtualdrive.physicaldrives.each do |id,physicaldrive|
            lsiarrayout += "    |  |-- pd #{physicaldrive.to_str}\n"
          end
        end
      end
      lsiarrayout
    end

    class Adapter

      attr_reader :id
      attr_accessor :virtualdrives, :physicaldrives, :rawattributes

      def initialize(id)
        @id = id
        @rawattributes = {}
        @lsiarray = nil
        @virtualdrives = []
        @physicaldrives = []
      end

    end

    class VirtualDrive

      STATES = {
          :optimal              => 'Optimal',
          :degraded             => 'Degraded',
          :partial_degraded     => 'Partial Degraded',
          :failed               => 'Failed',
          :offline              => 'Offline'
      }

      attr_reader :id
      attr_accessor :rawattributes, :raidlevel, :size, :state, :physicaldrives

      def initialize(id)
        @id = id
        @rawattributes = {}
        @physicaldrives = {}
        @_raidlevel = OpenStruct.new
      end

      def raidlevel
        [@_raidlevel.primary,@_raidlevel.secondary]
      end

      def raidlevel=raidlevel
        raise "raid level must be [primary,secondary]" unless raidlevel.size == 2
        @_raidlevel.primary = raidlevel[0].to_i
        @_raidlevel.secondary = raidlevel[1].to_i
      end

      def to_s
        "[VD] %4s %18s %7.2f %s %d" % [ @id, @state, @size, self.raidlevel, @physicaldrives.size ]
      end

    end

    class PhysicalDrive

      STATES = {
          :online               => 'Online',
          :unconfigured_good    => 'Unconfigured Good',
          :hotspare             => 'Hotspare',
          :failed               => 'Failed',
          :rebuild              => 'Rebuild',
          :unconfigured_bad     => 'Unconfigured Bad',
          :missing              => 'Missing',
          :offline              => 'Offline'
      }

      SPINS = {
          :spun_up               => 'Spun up'
      }

      # Physical drives are keyed by :id -> e<enclosure>s<slot>

      attr_accessor :id, :rawattributes, :deviceid, :size, :state, :slot, :mediaerrors, :predictivefailure, :inquirydata, :mediatype, :virtualdrives, :target, :enclosure, :spin, :pdtype

      def initialize
        @id = nil
        @target = nil
        @rawattributes = {}
        @deviceid = nil
        @_size = OpenStruct.new
        @state = nil
        @spin = nil
        @slot = nil
        @enclosure = nil
        @mediaerrors = nil
        @predictivefailure = nil
        @inquirydata = nil
        @mediatype = nil
        @pdtype = nil
        @virtualdrives = []
      end

      def deviceid
        @deviceid
      end

      def deviceid=(deviceid)
        @deviceid = deviceid
      end

      def id
        "e#{@enclosure.to_s}s#{@slot.to_s}".to_sym
      end

      def ==(anotherphysicaldrive)
        self.id == anotherphysicaldrive.id
      end

      def size=size
        raise "size must be specified as [number,unit]" unless size.size == 2
        @_size.number = size[0].to_f
        @_size.unit = size[1].to_s
      end

      def size
        "%.2f%s" % [@_size.number,@_size.unit]
      end

      def to_s
        "[PD] %8s %4s %19s %8.2f%s %5s %5s %3d %3d   %s" % [ self.id, @deviceid, "#{@state}:#{@spin}", @_size.number, @_size.unit, @mediatype, @pdtype, @mediaerrors, @predictivefailure, @inquirydata  ]
      end

    end
  end
end
