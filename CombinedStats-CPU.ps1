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

$CpuPercent = ((Get-counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Processor Percent Usage"}) | convertto-json

$CpuQueueLength = ((Get-counter -Counter "\System\Processor Queue Length" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Processor Queue Length"}) | convertto-json

$CpuPrivilegedTime = ((Get-counter -Counter "\Processor(_total)\% Privileged Time" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Processor Privileged Time"}) | convertto-json

$CpuUserTime = ((Get-counter -Counter "\Processor(_total)\% User Time" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Processor User Time"}) | convertto-json

Send-JsonOverTcp ODELKS01 5560 "$CpuPercent"
Send-JsonOverTcp ODELKS01 5560 "$CpuQueueLength"
Send-JsonOverTcp ODELKS01 5560 "$CpuPrivilegedTime"
Send-JsonOverTcp ODELKS01 5560 "$CpuUserTime"