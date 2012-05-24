require 'rubygems'
require 'open4'
include Open4

module Elesai

  class SendNSCA

    NAGIOS_OK = 0
    NAGIOS_WARNING = 1
    NAGIOS_CRITICAL = 2
    NAGIOS_UNKNOWN = 3

    @send_nsca_bin = "/usr/local/bin/send_nsca"
    @send_nsca_cfg = "/usr/local/etc/nagios/send_nsca.cfg"
    class << self; attr_accessor :send_nsca_bin, :send_nsca_cfg end

    class Error < StandardError; end
    class SendNSCAError < Error; end

    def initialize(nagioshostname,hostname,svc_descr)
      @nagioshostname = nagioshostname
      @hostname = hostname
      @svc_descr = svc_descr
    end

    def send(rt,svc_output)
      begin
        pid, stdin, stdout, stderr = popen4("#{SendNSCA.send_nsca_bin} -H #{@nagioshostname} -c #{SendNSCA.send_nsca_cfg}")
        stdin.write("#{@hostname}\t#{@svc_descr}\t#{rt}\t#{svc_output}\n")
        stdin.close
        ignored, status = Process::waitpid2 pid
        stdoutbucket = stdout.readlines[0]
        raise SendNSCAError, stdoutbucket.strip unless status.exitstatus == 0
      rescue Errno::ENOENT, Errno::EACCES => e
        raise SendNSCAError, e.message
      end
    end

  end
end