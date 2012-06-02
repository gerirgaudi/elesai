require 'ostruct'

module Elesai

  class LSIArray

    attr_reader :adapters, :virtualdrives, :physicaldrives, :enclosures

    def initialize
      @adapters = []
      @virtualdrives = []
      @physicaldrives = {}
      @enclosures = []
      @spans = []

#      PDinfo_aAll.new.parse
    end

    def create_adapter(id)
      Adapter.new(id)
    end

    def add_adapter(adapter)
      @adapters[adapter.id] = adapter
    end

    def add_virtualdrive(virtualdrive)
      @virtualdrives.push(virtualdrive)
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

      attr_accessor :id, :virtualdrives, :physicaldrives, :rawattributes

      def initialize
        @id = nil
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

      def initialize
        @id = nil
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

#      def to_s
#        "[VD] %4s %18s %7.2f %s %d" % [ @id, @state, @size, self.raidlevel, @physicaldrives.size ]
#      end

    end

    ### Physical Drive

    class PhysicalDrive < Hash

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
          :spun_up              => 'Spun up'
      }

      class Size < Struct.new(:number, :unit); end
      class RaidLevel < Struct.new(:primary, :secondary); end
      class FirmwareState < Struct.new(:state, :spin); end

    end
  end
end


































