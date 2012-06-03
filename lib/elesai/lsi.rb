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

      megacli = PDinfo_aAll.new
      megacli.parse!(self,MEGACLI_PDINFO_AALL_OUT)
    end

    def add_adapter(a)
      @adapters[a[:id]] = a if @adapters[a[:id]].nil?
    end

    def add_virtualdrive(vd)
      @virtualdrives.push(vd)
    end

    def add_physicaldrive(pd)
      @physicaldrives[pd._id] = pd if @physicaldrives[pd._id].nil?
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

    class Adapter < Hash

      def inspect
        "#{self.class}:#{self.__id__}"
      end

      def _id
        "#{self[:id]}"
      end

    end

    class VirtualDrive < Hash

      STATES = {
          :optimal              => 'Optimal',
          :degraded             => 'Degraded',
          :partial_degraded     => 'Partial Degraded',
          :failed               => 'Failed',
          :offline              => 'Offline'
      }

      class Size < Struct.new(:number, :unit); end
      class RaidLevel < Struct.new(:primary, :secondary); end

      def inspect
        "#{self.class}:#{self.__id__}"
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

      def _id
        "e#{self[:enclosuredeviceid].to_s}s#{self[:slotnumber].to_s}".to_sym
      end

      def to_s
        self.__id__
      end

      def inspect
        "#{self.class}:#{self.__id__}"
      end

      class Size < Struct.new(:number, :unit); end
      class FirmwareState < Struct.new(:state, :spin); end

    end
  end
end
