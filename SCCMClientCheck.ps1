$contentID = 'CA100003'
$checkSCCM = (Get-WmiObject -Namespace ROOT\CCM\SoftMgmtAgent -Class CCM_ExecutionRequestEx) | ? {$_.ContentID -eq $contentID} | ? {$_.CompletionState -ne "Failure"} | ?{$_.State -eq "Completed" } 
if ($checkSCCM) { Write-Host "SCCM task completed" }
