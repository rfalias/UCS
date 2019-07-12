#Requires UCS PowerTool - https://community.cisco.com/t5/cisco-developed-ucs-integrations/cisco-ucs-powertool-suite-powershell-modules-for-cisco-ucs/ta-p/3639523
#Expects vHBA Names to end with either a number or A/B(1,2,3) (Ex. server-vhba1 OR server-vhbaA, servervhbaB2)
$ucsEnvironment = "ucsm_server"
disconnect-ucs
Connect-Ucs $ucsEnvironment
$even = New-Object System.Collections.ArrayList
$odd = New-Object System.Collections.ArrayList
$hostlist = Get-UcsServiceProfile
foreach ($h in $hostlist)
{
    $hname = $h.name
    $hba = $h | get-ucsvhba
    foreach ($h in $hba){
        $addr = $h.addr
        $hbaname = $h.name
        $hbaNumber = $hbaname.Substring($hbaname.Length-1)
        $hbaLast2 = $hbaname.Substring($hbaname.Length-2)
        if ($hbaLast2 -eq "-A")
        {
            $hbaNumber = 0
        }
        elseif ($hbaLast2 -eq "A2")
        {
            $hbaNumber = 1
        }
        elseif ($hbaLast2 -eq "-B")
        {
            $hbaNumber = 2
        }
        elseif ($hbaLast2 -eq "B2")
        {
            $hbaNumber = 3
        }
        if ($addr -ne "vnic-derived" -and $addr -ne "derived")
        {
           if ($hbaNumber % 2 -eq 0)
           {
               $cmdhbaname = "vhba" + $hbaNumber
               $aliasEven = "device-alias name $hname-$cmdhbaname pwwn $addr"
               $even.Add($aliasEven)
           }
           else
           {
               $cmdhbaname = "vhba" + $hbaNumber
               $aliasOdd = "device-alias name $hname-$cmdhbaname pwwn $addr"
               $odd.Add($aliasOdd)
           }
        }
    }
}
remove-item -path "C:\temp\even_alias $ucsEnvironment.txt"
remove-item -path "C:\temp\odd_alias $ucsEnvironment.txt"
write-host "-----EVEN HBA-----"
foreach ($e in $even)
{
    write-host $e
    $e | add-content -Path "C:\temp\even_alias $ucsEnvironment.txt"
}
write-host ""
write-host "-----ODD HBA-----"
foreach ($o in $odd)
{
    write-host $o
    
    $o | add-content -Path "C:\temp\odd_alias $ucsEnvironment.txt"
}
