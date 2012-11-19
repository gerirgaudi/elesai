module Elesai; module Action

  class Show

    COMPONENTS = %w(adapter virtualdrive vd physicaldrive pd bbu)

    def initialize(arguments,options)

      @options = options
      @arguments = arguments

      @component = nil

      opts = OptionParser.new
      opts.banner = "Usage: #{ID} [options] show <component>"
      opts.separator ""
      opts.separator "      <component> is physicaldisk|pd, virtualdisk|vd, bbu"
      opts.order!(@arguments)

      options_valid?
      arguments_valid?
      process_arguments

      @show = { :adapter => self.method(:show_adapter),
                :virtualdrive => self.method(:show_virtualdrive),
                :physicaldrive => self.method(:show_physicaldrive),
                :bbu => self.method(:show_bbu)
      }
    end

    def exec
      @lsi = LSI.new(:megacli => @options[:megacli], :fake => @options[:fake], :hint => @component)
      @show[@component].call
    end

    protected

    def options_valid?
      true
    end

    def arguments_valid?
      raise ArgumentError, "missing component" if @arguments.size == 0
      raise ArgumentError, "too many components" if @arguments.size > 1
      raise ArgumentError, "invalid component #{@arguments[0]}" unless COMPONENTS.include? @arguments[0]
      true
    end

    def process_arguments
      @component = case @arguments[0].to_sym
        when :vd then :virtualdrive
        when :pd then :physicaldrive
        else @arguments[0].to_sym
      end
    end

    def show_virtualdrive
      @lsi.virtualdrives.each do |virtualdrive|
        print "#{virtualdrive}\n"
      end
    end

    def show_physicaldrive
      @lsi.physicaldrives.each do |id,physicaldrive|
        print "#{physicaldrive}\n"
      end
    end

    def show_bbu
      @lsi.bbus.each do |bbu|
        print "#{bbu}\n"
      end
    end

    def show_adapter
      @lsi.adapters.each do |adapter|
        print "#{adapter}\n"
      end
    end

  end

end end