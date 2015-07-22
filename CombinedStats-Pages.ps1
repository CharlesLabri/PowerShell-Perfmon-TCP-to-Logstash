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

$MemoryPagesSec = ((Get-counter -Counter "\Memory\Pages/sec" -SampleInterval 1 -MaxSamples 1).countersamples | select-object -Property @{ expression={$_.Path}; label="Host Performance Query"},@{ expression={ $_.CookedValue}; label="Memory Pages/Sec"}) | convertto-json

Send-JsonOverTcp ODELKS01 5562 "$MemoryPagesSec"