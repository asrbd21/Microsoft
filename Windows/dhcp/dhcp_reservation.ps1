$DHCPStaticEntries = Import-Csv -Path "c:\DRIPCustomizer-ipv4-dhcp.csv" -delimiter ','


For($i = 0; $i -lt $DHCPStaticEntries.count; $i++){

    $EndMAC = "{0:x2}" -f $i
    $FQDN = $DHCPStaticEntries[$i].VMName+'.ASRBD21.local'

    Add-DhcpServerv4Reservation -ComputerName SRV-01.ASRBD21.local -ScopeID 10.59.1.0 -IPAddress $DHCPStaticEntries[$i].IPAddress -Name $FQDN -ClientId "00-73-21-DE-AD-$EndMAC" -Description "Reservation Pour $($DHCPStaticEntries[$i].VMName)"
    if($DHCPStaticEntries[$i].PrimaryWINS){
        Set-DhcpServerv4OptionValue -ComputerName SRV-01.ASRBD21.local -ReservedIP $DHCPStaticEntries[$i].IPAddress -DnsServer 10.59.0.16 -DnsDomain ASRBD21.local -Router 10.59.1.2 -WinsServer $DHCPStaticEntries[$i].PrimaryWINS
    } else {
        Set-DhcpServerv4OptionValue -ComputerName SRV-01.ASRBD21.local -ReservedIP $DHCPStaticEntries[$i].IPAddress -DnsServer 10.59.0.16 -DnsDomain ASRBD21.local -Router 10.59.1.2
    }
    Write-host -Foreground yellow "Ajout de la réservation pour l'hôte $($DHCPStaticEntries[$i].VMName)"

}

