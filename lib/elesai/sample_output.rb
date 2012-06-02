module Elesai

    MEGACLI_PDINFO_AALL_OUT = <<END

Adapter #0

Enclosure Device ID: 252
Slot Number: 0
Enclosure position: 0
Device Id: 11
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 223.570 GB [0x1bf244b0 Sectors]
Non Coerced Size: 223.070 GB [0x1be244b0 Sectors]
Coerced Size: 223.062 GB [0x1be20000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x4433221103000000
Connected Port Number: 3(path0)
Inquiry Data: CVPR140201KZ300EGN  INTEL SSDSA2CW300G3                     4PC10362
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: 3.0Gb/s
Link Speed: 3.0Gb/s
Media Type: Solid State Device
Drive:  Not Certified
Drive Temperature : N/A



Enclosure Device ID: 252
Slot Number: 1
Enclosure position: 0
Device Id: 10
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 223.570 GB [0x1bf244b0 Sectors]
Non Coerced Size: 223.070 GB [0x1be244b0 Sectors]
Coerced Size: 223.062 GB [0x1be20000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x4433221102000000
Connected Port Number: 2(path0)
Inquiry Data: CVPR141300K9300EGN  INTEL SSDSA2CW300G3                     4PC10362
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: 3.0Gb/s
Link Speed: 3.0Gb/s
Media Type: Solid State Device
Drive:  Not Certified
Drive Temperature : N/A



Enclosure Device ID: 252
Slot Number: 2
Enclosure position: 0
Device Id: 9
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 223.570 GB [0x1bf244b0 Sectors]
Non Coerced Size: 223.070 GB [0x1be244b0 Sectors]
Coerced Size: 223.062 GB [0x1be20000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x4433221101000000
Connected Port Number: 1(path0)
Inquiry Data: CVPR140100MQ300EGN  INTEL SSDSA2CW300G3                     4PC10362
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: 3.0Gb/s
Link Speed: 3.0Gb/s
Media Type: Solid State Device
Drive:  Not Certified
Drive Temperature : N/A



Enclosure Device ID: 252
Slot Number: 3
Enclosure position: 0
Device Id: 8
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 223.570 GB [0x1bf244b0 Sectors]
Non Coerced Size: 223.070 GB [0x1be244b0 Sectors]
Coerced Size: 223.062 GB [0x1be20000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x4433221100000000
Connected Port Number: 0(path0)
Inquiry Data: CVPR141301KG300EGN  INTEL SSDSA2CW300G3                     4PC10362
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: 3.0Gb/s
Link Speed: 3.0Gb/s
Media Type: Solid State Device
Drive:  Not Certified
Drive Temperature : N/A



Enclosure Device ID: 252
Slot Number: 4
Enclosure position: 0
Device Id: 12
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 223.570 GB [0x1bf244b0 Sectors]
Non Coerced Size: 223.070 GB [0x1be244b0 Sectors]
Coerced Size: 223.062 GB [0x1be20000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x4433221104000000
Connected Port Number: 4(path0)
Inquiry Data: CVPR138405AQ300EGN  INTEL SSDSA2CW300G3                     4PC10362
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: 3.0Gb/s
Link Speed: 3.0Gb/s
Media Type: Solid State Device
Drive:  Not Certified
Drive Temperature : N/A



Enclosure Device ID: 252
Slot Number: 5
Enclosure position: 0
Device Id: 13
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 223.570 GB [0x1bf244b0 Sectors]
Non Coerced Size: 223.070 GB [0x1be244b0 Sectors]
Coerced Size: 223.062 GB [0x1be20000 Sectors]
Firmware state: Hotspare, Spun Up
SAS Address(0): 0x4433221105000000
Connected Port Number: 5(path0)
Inquiry Data: CVPR140100TT300EGN  INTEL SSDSA2CW300G3                     4PC10362
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: 3.0Gb/s
Link Speed: 3.0Gb/s
Media Type: Solid State Device
Drive:  Not Certified
Drive Temperature : N/A


Hotspare Information:
Type: Dedicated, is revertible
Array #: 0


Exit Code: 0x00

END

    MEGACLI_LDPDINFO_AALL_OUT = <<END

Adapter #0

Number of Virtual Disks: 7
Virtual Drive: 0 (Target Id: 0)
Name                :
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 278.464 GB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives    : 2
Span Depth          : 1
Default Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Number of Spans: 1
Span: 0 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 252
Slot Number: 0
Enclosure position: 0
Device Id: 16
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SAS
Raw Size: 279.396 GB [0x22ecb25c Sectors]
Non Coerced Size: 278.896 GB [0x22dcb25c Sectors]
Coerced Size: 278.464 GB [0x22cee000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x5000c5002bd9506d
SAS Address(1): 0x0
Connected Port Number: 0(path0)
Inquiry Data: SEAGATE ST3300657SS     00066SJ01W4G
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature :34C (93.20 F)




PD: 1 Information
Enclosure Device ID: 252
Slot Number: 1
Enclosure position: 0
Device Id: 17
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SAS
Raw Size: 279.396 GB [0x22ecb25c Sectors]
Non Coerced Size: 278.896 GB [0x22dcb25c Sectors]
Coerced Size: 278.464 GB [0x22cee000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x5000c5002be05035
SAS Address(1): 0x0
Connected Port Number: 1(path0)
Inquiry Data: SEAGATE ST3300657SS     00066SJ01TTR
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature :31C (87.80 F)



Virtual Drive: 1 (Target Id: 1)
Name                :
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 20.0 GB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives per span:2
Span Depth          : 2
Default Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Number of Spans: 2
Span: 0 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 252
Slot Number: 4
Enclosure position: 0
Device Id: 18
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086e5f6f7e
Connected Port Number: 4(path0)
Inquiry Data:             9WM1G6MXST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




PD: 1 Information
Enclosure Device ID: 252
Slot Number: 5
Enclosure position: 0
Device Id: 28
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e076d6f7b69
Connected Port Number: 5(path0)
Inquiry Data:             9WM0FFYCST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A



Span: 1 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 252
Slot Number: 6
Enclosure position: 0
Device Id: 22
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086e826d70
Connected Port Number: 6(path0)
Inquiry Data:             9WM1GYKJST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




PD: 1 Information
Enclosure Device ID: 252
Slot Number: 7
Enclosure position: 0
Device Id: 23
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086d815372
Connected Port Number: 7(path0)
Inquiry Data:             9WM1FX1LST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A



Virtual Drive: 2 (Target Id: 2)
Name                :
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 3.616 TB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives per span:2
Span Depth          : 2
Default Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Number of Spans: 2
Span: 0 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 252
Slot Number: 4
Enclosure position: 0
Device Id: 18
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086e5f6f7e
Connected Port Number: 4(path0)
Inquiry Data:             9WM1G6MXST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




PD: 1 Information
Enclosure Device ID: 252
Slot Number: 5
Enclosure position: 0
Device Id: 28
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e076d6f7b69
Connected Port Number: 5(path0)
Inquiry Data:             9WM0FFYCST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A



Span: 1 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 252
Slot Number: 6
Enclosure position: 0
Device Id: 22
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086e826d70
Connected Port Number: 6(path0)
Inquiry Data:             9WM1GYKJST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




PD: 1 Information
Enclosure Device ID: 252
Slot Number: 7
Enclosure position: 0
Device Id: 23
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086d815372
Connected Port Number: 7(path0)
Inquiry Data:             9WM1FX1LST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A



Virtual Drive: 3 (Target Id: 3)
Name                :
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 278.464 GB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives    : 2
Span Depth          : 1
Default Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Number of Spans: 1
Span: 0 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 252
Slot Number: 2
Enclosure position: 0
Device Id: 20
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SAS
Raw Size: 279.396 GB [0x22ecb25c Sectors]
Non Coerced Size: 278.896 GB [0x22dcb25c Sectors]
Coerced Size: 278.464 GB [0x22cee000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x5000c5002bda7555
SAS Address(1): 0x0
Connected Port Number: 2(path0)
Inquiry Data: SEAGATE ST3300657SS     00066SJ02BCX
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature :31C (87.80 F)




PD: 1 Information
Enclosure Device ID: 252
Slot Number: 3
Enclosure position: 0
Device Id: 21
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SAS
Raw Size: 279.396 GB [0x22ecb25c Sectors]
Non Coerced Size: 278.896 GB [0x22dcb25c Sectors]
Coerced Size: 278.464 GB [0x22cee000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x5000c5002be5cdd9
SAS Address(1): 0x0
Connected Port Number: 3(path0)
Inquiry Data: SEAGATE ST3300657SS     00066SJ025LP
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature :29C (84.20 F)



Virtual Drive: 4 (Target Id: 4)
Name                :
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 20.0 GB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives per span:2
Span Depth          : 2
Default Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Number of Spans: 2
Span: 0 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 253
Slot Number: 0
Enclosure position: 0
Device Id: 24
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086e6f5474
Connected Port Number: 8(path0)
Inquiry Data:             9WM1GF2NST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




PD: 1 Information
Enclosure Device ID: 253
Slot Number: 1
Enclosure position: 0
Device Id: 25
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086e825a5b
Connected Port Number: 9(path0)
Inquiry Data:             9WM1GY85ST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A



Span: 1 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 253
Slot Number: 2
Enclosure position: 0
Device Id: 26
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086f6a5274
Connected Port Number: 10(path0)
Inquiry Data:             9WM1HA0NST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




PD: 1 Information
Enclosure Device ID: 253
Slot Number: 3
Enclosure position: 0
Device Id: 27
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086960786a
Connected Port Number: 11(path0)
Inquiry Data:             9WM1B7VDST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A



Virtual Drive: 5 (Target Id: 5)
Name                :
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 3.616 TB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives per span:2
Span Depth          : 2
Default Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteBack, ReadAdaptive, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Number of Spans: 2
Span: 0 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 253
Slot Number: 0
Enclosure position: 0
Device Id: 24
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086e6f5474
Connected Port Number: 8(path0)
Inquiry Data:             9WM1GF2NST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




PD: 1 Information
Enclosure Device ID: 253
Slot Number: 1
Enclosure position: 0
Device Id: 25
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Degraded, Spun Up
SAS Address(0): 0x9281e086e825a5b
Connected Port Number: 9(path0)
Inquiry Data:             9WM1GY85ST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A



Span: 1 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 253
Slot Number: 2
Enclosure position: 0
Device Id: 26
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086f6a5274
Connected Port Number: 10(path0)
Inquiry Data:             9WM1HA0NST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




PD: 1 Information
Enclosure Device ID: 253
Slot Number: 3
Enclosure position: 0
Device Id: 27
Sequence Number: 2
Media Error Count: 0
Other Error Count: 67024
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e086960786a
Connected Port Number: 11(path0)
Inquiry Data:             9WM1B7VDST32000644NS                            SN11
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A



Virtual Drive: 6 (Target Id: 6)
Name                :
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 1.817 TB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives    : 2
Span Depth          : 1
Default Cache Policy: WriteBack, ReadAheadNone, Cached, No Write Cache if Bad BBU
Current Cache Policy: WriteBack, ReadAheadNone, Cached, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Number of Spans: 1
Span: 0 - Number of PDs: 2

PD: 0 Information
Enclosure Device ID: 253
Slot Number: 4
Enclosure position: 0
Device Id: 30
Sequence Number: 2
Media Error Count: 0
Other Error Count: 8335
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Degraded, Spun Up
SAS Address(0): 0x9281e0c805d636b
Connected Port Number: 12(path0)
Inquiry Data:             9WM5Y4AEST32000644NS                            SN12
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




PD: 1 Information
Enclosure Device ID: 253
Slot Number: 5
Enclosure position: 0
Device Id: 29
Sequence Number: 2
Media Error Count: 0
Other Error Count: 8335
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 1.819 TB [0xe8e088b0 Sectors]
Non Coerced Size: 1.818 TB [0xe8d088b0 Sectors]
Coerced Size: 1.817 TB [0xe8b6d000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x9281e0e7361555a
Connected Port Number: 13(path0)
Inquiry Data:             9WM7L834ST32000644NS                            SN12
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None
Device Speed: Unknown
Link Speed: Unknown
Media Type: Hard Disk Device
Drive Temperature : N/A




Exit Code: 0x00
END


end