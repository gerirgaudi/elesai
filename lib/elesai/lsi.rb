require 'elesai/megacli'

module Elesai

  class LSI

    attr_reader :adapters, :virtualdrives, :physicaldrives, :bbus, :enclosures

    def initialize(opts)
      @adapters = []
      @virtualdrives = []
      @physicaldrives = {}
      @enclosures = []
      @spans = []
      @bbus = []

      case opts[:hint]
        when :physicaldrive
          Megacli::PDlist_aAll.new.parse!(self,opts)
        when :virtualdrive
          Megacli::LDPDinfo_aAll.new.parse!(self,opts)
        when :adapter
          Megacli::AdpAllInfo_aAll.new.parse!(self,opts)
        when :bbu
          Megacli::AdpBbuCmd_aAll.new.parse!(self,opts)
        else
          Megacli::AdpAllInfo_aAll.new.parse!(self,opts)
          Megacli::PDlist_aAll.new.parse!(self,opts)
          Megacli::LDPDinfo_aAll.new.parse!(self,opts)
          Megacli::AdpBbuCmd_aAll.new.parse!(self,opts)
      end
    end

    def add(component)
      case component
        when Adapter
          @adapters[component[:id]] = component if @adapters[component[:id]].nil?
        when VirtualDrive
          @virtualdrives.push(component)
        when PhysicalDrive
          @physicaldrives[component._id] = component if @physicaldrives[component._id].nil?
          return @physicaldrives[component._id]
        when BBU
          @bbus.push(component)
        else
          raise StandardError, "invalid component #{component.class}"
      end
    end









    class Adapter < Hash

      class Section < Hash
        attr_reader :section
        def initialize(section)
          @section = section
        end
        def inspect
          "#{self.class}:#@section:#{self.__id__}"
        end
      end

      def initialize
        self[:virtualdrives] = []
        self[:physicaldrives] = {}
        super
      end

      def _id
        "#{self[:id]}"
      end

      def inspect
        "#{self.class}:#{self.__id__}"
      end

      def add_physicaldrive(pd)
        self[:physicaldrives][pd._id] = pd unless self[:physicaldrives][pd._id].nil?
      end

      def add_section(section)
        self[section.section] = section
      end

      def to_s
        "[ADAPTER] %2s  %s  %s %s  %s" % [ self._id,self[:versions][:productname].gsub(/\s+/,'_'),self[:versions][:fwpackagebuild],self[:imageversions][:fwversion],self[:hwconfiguration][:sasaddress] ]
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

      class Size < Struct.new(:number, :unit)
        def to_s ; "%8.2f%s" % [self.number,self.unit] end
      end
      class RaidLevel < Struct.new(:primary, :secondary)
        def to_s ; "raid%s:raid%s" % [self.primary,self.secondary] end
      end

      def initialize
        self[:physicaldrives] = []
      end

      def _id
        self[:targetid]
      end

      def inspect
        "#{self.class}:#{self.__id__}"
      end

      def add_physicaldrive(pd)

      end

      def to_s
        "[VD] %4s %18s %s %s %d" % [ self._id, self[:state], self[:size], self[:raidlevel], self[:physicaldrives].size ]
      end

    end

    class PhysicalDrive < Hash

      STATES = {
          :online               => 'Online',
          :unconfigured_good    => 'Unconfigured(good)',
          :hotspare             => 'Hotspare',
          :failed               => 'Failed',
          :rebuild              => 'Rebuild',
          :unconfigured_bad     => 'Unconfigured(bad)',
          :missing              => 'Missing',
          :offline              => 'Offline'
      }

      SPINS = {
          :spun_up              => 'Spun up'
      }

      class Size < Struct.new(:number, :unit)
        def to_s ; "%8.2f%s" % [self.number,self.unit] end
      end
      class FirmwareState < Struct.new(:state, :spin)
        def to_s
          "#{self.state}:#{self.spin}"
        end
      end

      def initialize
        self[:_adapter] = nil
        self[:_virtualdrives] = []
      end

      def _id
        "e#{self[:enclosuredeviceid].to_s}s#{self[:slotnumber].to_s}".to_sym
      end

      def to_s
        keys = [:deviceid, :firmwarestate, :coercedsize, :mediatype, :pdtype, :mediaerrorcount, :predictivefailurecount,:inquirydata]
        #"[PD] %8s %4s %19s %8.2f%s %5s %5s %3d %3d   %s" % [ self.id, @deviceid, "#{@state}:#{@spin}", @_size.number, @_size.unit, @mediatype, @pdtype, @mediaerrors, @predictivefailure, @inquirydata  ]
        "[PD] %8s %4s %19s %s %5s %5s %3d %3d  a%s  %s" % [ self._id, self[:deviceid], self[:firmwarestate], self[:coercedsize], self[:mediatype], self[:pdtype], self[:mediaerrorcount], self[:predictivefailurecount], self[:_adapter]._id, self[:inquirydata] ]
      end

      def inspect
        "#{self.class}:#{self.__id__}"
      end

      def add_adapter(a)
        self[:_adapter] = a
      end

      def get_adapter
        self[:_adapter]
      end

      def add_virtualdrive(vd)
         self[:_virtualdrives][vd._id] = vd if self[:_virtualdrives][vd._id].nil?
      end

      def get_virtualdrive(vd_id)
        self[:_virtualdrives][vd_id]
      end

      def get_virtualdrives
        self[:_virtualdrives]
      end
    end

    class BBU < Hash

      class NumberUnit < Struct.new(:number, :unit)
        def to_s ; "%d%s" % [self.number,self.unit] end
      end

      class Section < Hash
        attr_reader :section
        def initialize(section)
          @section = section
        end
        def inspect
          "#{self.class}:#{@section.capitalize}:#{self.__id__}"
        end
      end

      def initialize
      end

      def _id
        self[:id]
      end

      def add_section(section)
        self[section.section] = section
      end

      def inspect
        "#{self.class}:#{self.__id__}"
      end

      def to_s
        capacityinfo_absolutestateofcharge = self[:batterytype] == 'iBBU' ? self[:capacityinfo][:absolutestateofcharge] : '-'
        capacityinfo_remainingcapacity = self[:batterytype] == 'iBBU' ? self[:capacityinfo][:remainingcapacity] : '-'
        "[BBU] %s %-5s %-4s %-11s %3s:%-8s  %s:%s  %s:%s  %7s:%-4s  %s" % [self[:id],self[:batterytype],self[:designinfo][:devicechemistry],self[:firmwarestatus][:chargingstatus],self[:firmwarestatus][:learncycleactive],self[:firmwarestatus][:learncyclestatus],self[:voltage].gsub(/\s/,''),self[:firmwarestatus][:voltage],self[:temperature].gsub(/\s/,''),self[:firmwarestatus][:temperature],capacityinfo_remainingcapacity,capacityinfo_absolutestateofcharge,self[:properties][:nextlearntime]]
      end
    end
  end
end
