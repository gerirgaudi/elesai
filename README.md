# OVERVIEW

*Elesai* is a wrapper around LSI's `MegaCli` utility that provides access to common types of information about the RAID controllers via a `show` action without the need to speak martian. It is a line-oriented tool so that it can be combined with other Unix command-line tools to process and manipulate the data (i.e., `sed`, `awk`, and friends). It also provides a `check` action (currently as a Nagios plugin in both active and passive modes) which monitors the health of the array and its components and reports it accordingly (this is not yet configurable).

# SYNOPSIS

    elesai [global-options] <action> [action-options] [<component>]

where:

* `<action>` is one of `show` or `check`
* `<component>` is one of `virtualdrive` (or `vd`) or `physicaldrive` (or `pd`) (for `show` action)

Global options include:

* `-d`, `--debug`: enable *debug* mode
* `-f`, `--fake DIRECTORY`: specifies path to directory containing output of MegaCli invocations:
	* `ldlist_aall`: output from `MegaCli -pdlist -aall`
	* `ldpdinfo_aall`: output from `MegaCli -ldpdinfo -aall`
* `-m`, `--megacli MEGACLI`: path to `MegaCli` binary (if noth in `$PATH`)
* `-a`, `--about`: display general information about `elesai`
* `-V`, `--version`: display `elesai`'s version

The `<check>` can have options specific to itself:

* `-M`, `--monitor MONITOR`:            Monitoring system (default: `nagios`)
* `-m`, `--mode [active|passive]`:      Monitoring mode
* `-H`, `--nsca_hostname HOSTNAME`:     NSCA hostname to send passive checks
* `-c`, `--config CONFIG`:              Path to Senedsa (send_nsca) configuration
* `-S`, `--svc_descr SVC_DESCR`:        Nagios service description

*Elesai* uses [Senedsa](https://rubygems.org/gems/senedsa "Senedsa") for Nagios passive check submission, which can use a configuration file to set options.

# Invocations

## Normal Invocation

    root@boxie:~# elesai show pd | sort -k 4
    [PD]   e253s3   27       online:spunup     1.82TB   HDD  SATA   0   0   9WM1B7VDST32000644NS SN11
    [PD]   e252s7   23       online:spunup     1.82TB   HDD  SATA   0   0   9WM1FX1LST32000644NS SN11
    [PD]   e253s0   24       online:spunup     1.82TB   HDD  SATA   0   0   9WM1GF2NST32000644NS SN11
    [PD]   e253s1   25       online:spunup     1.82TB   HDD  SATA   0   0   9WM1GY85ST32000644NS SN11
    [PD]   e252s6   22       online:spunup     1.82TB   HDD  SATA   0   0   9WM1GYKJST32000644NS SN11
    [PD]   e253s2   26       online:spunup     1.82TB   HDD  SATA   0   0   9WM1HA0NST32000644NS SN11
    [PD]   e253s5   29       online:spunup     1.82TB   HDD  SATA   0   0   9WM7L834ST32000644NS SN12
    [PD]   e252s4   12       online:spunup   223.06GB   SSD  SATA   0   0   CVPR138405AQ300EGN INTEL SSDSA2CW300G3 4PC10362
    [PD]   e252s2    9       online:spunup   223.06GB   SSD  SATA   0   0   CVPR140100MQ300EGN INTEL SSDSA2CW300G3 4PC10362
    [PD]   e252s0   11       online:spunup   223.06GB   SSD  SATA   0   0   CVPR140201KZ300EGN INTEL SSDSA2CW300G3 4PC10362
    [PD]   e252s1   10       online:spunup   223.06GB   SSD  SATA   0   0   CVPR141300K9300EGN INTEL SSDSA2CW300G3 4PC10362
    [PD]   e252s3    8       online:spunup   223.06GB   SSD  SATA   0   0   CVPR141301KG300EGN INTEL SSDSA2CW300G3 4PC10362
    [PD]   e253s4   30       failed:spunup     1.82TB   HDD  SATA   0   0   9WM5Y4AEST32000644NS SN12
    [PD]   e252s5   13     hotspare:spunup   223.06GB   SSD  SATA   0   0   CVPR140100TT300EGN INTEL SSDSA2CW300G3 4PC10362
    
## Remote Invocation

Pipe output to `elesai`:

	root@boxie:~# ssh server.example.com sudo MegaCli -pdlist -aall | elesai show pd
	[PD]   e252s0   16       online:spunup   278.46GB   HDD   SAS   0   0  a0  SEAGATE ST3300657SS 00066SJ01W4G
	[PD]   e252s1   17       online:spunup   278.46GB   HDD   SAS   0   0  a0  SEAGATE ST3300657SS 00066SJ01TTR
	[PD]   e252s2   20       online:spunup   278.46GB   HDD   SAS   0   0  a0  SEAGATE ST3300657SS 00066SJ02BCX
	[PD]   e252s3   21       online:spunup   278.46GB   HDD   SAS   0   0  a0  SEAGATE ST3300657SS 00066SJ025LP
	[PD]   e252s4   18       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM1G6MXST32000644NS SN11
	[PD]   e252s5   28       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM0FFYCST32000644NS SN11
	[PD]   e252s6   22       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM1GYKJST32000644NS SN11
	[PD]   e252s7   23       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM1FX1LST32000644NS SN11
	[PD]   e253s0   24       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM1GF2NST32000644NS SN11
	[PD]   e253s1   25       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM1GY85ST32000644NS SN11
	[PD]   e253s2   26       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM1HA0NST32000644NS SN11
	[PD]   e253s3   27       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM1B7VDST32000644NS SN11
	[PD]   e253s4   30       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM5Y4AEST32000644NS SN12
	[PD]   e253s5   29       online:spunup     1.82TB   HDD  SATA   0   0  a0  9WM7L834ST32000644NS SN12
	[PD]   e253s6   31  unconfigured(bad):     0.00KB   HDD   SAS   0   0  a0  SEAGATE ST33000650SS 0003Z29182VM
	[PD]   e253s7   32  unconfigured(bad):     0.00KB   HDD   SAS   0   0  a0  SEAGATE ST33000650SS 0003Z291A3QV
    
# STATUS

Very much in progress. The tool does not yet poke MegaCli itself.



