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

$NetworkReceived = ((Get-counter -Counter "\Network Interface(*)\Bytes Received/sec" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Network Bytes Received"}) | Where-Object {$_."Network Bytes Received" -ne 0} | convertto-json


$NetworkSent = ((Get-counter -Counter "\Network Interface(*)\Bytes Sent/sec" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Network Bytes Sent"}) | Where-Object {$_."Network Bytes Sent" -ne 0} | convertto-json

Send-JsonOverTcp ODELKS01 5563 "$NetworkReceived"
Send-JsonOverTcp ODELKS01 5563 "$NetworkSent"