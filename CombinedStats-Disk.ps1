Function Send-JsonOverTcp { 
 param ( [ValidateNotNullOrEmpty()] 
 [string] $LogstashServer, 
 [int] $Port, 
 $JsonObject) 
 $JsonString = $JsonObject -replace "`n",' ' -replace "`r",' ' -replace ' ',''
 $Ip = [System.Net.Dns]::GetHostAddresses($LogstashServer) 
 $Address = [System.Net.IPAddress]::Parse($Ip) 
 $Socket = New-Object System.Net.Sockets.TCPClient($Address,$Port) 
 $Stream = $Socket.GetStream() 
 $Writer = New-Object System.IO.StreamWriter($Stream)
 $Writer.WriteLine($JsonString)
 $Writer.Flush()
 $Stream.Close()
 $Socket.Close()
}

$DiskReadPerf = ((Get-counter -Counter "\PhysicalDisk(_total)\Avg. Disk sec/Write" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Disk_Read_Perf"}) | convertto-json

$DiskWritePerf = ((Get-counter -Counter "\PhysicalDisk(_total)\Avg. Disk sec/Write" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Disk_Write_Perf"}) | convertto-json

$DiskQueueLength = ((Get-counter -Counter "\PhysicalDisk(_total)\Avg. Disk Queue Length" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Disk_Queue_Length"}) | convertto-json

Send-JsonOverTcp ODELKS01 5561 "$DiskReadPerf"
Send-JsonOverTcp ODELKS01 5561 "$DiskWritePerf"
Send-JsonOverTcp ODELKS01 5561 "$DiskQueueLength" 