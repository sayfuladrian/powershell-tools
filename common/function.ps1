function Get-PublicIPAddress {
    $urls = @(
        "http://ifconfig.me/ip",
        "http://ipinfo.io/ip",
        "http://icanhazip.com",
        "http://api.ipify.org",
        "http://checkip.amazonaws.com",
        "http://ident.me"
    )

    foreach ($url in $urls) {
        try {
            $publicIP = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content.Trim()
            if ($publicIP) {
                return $publicIP
            }
        } catch {
            continue
        }
    }

    return "Unavailable"
}

function Get-LocalIPAddress {
    $physicalAdapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
    $physicalAdapterIndices = $physicalAdapters | Select-Object -ExpandProperty InterfaceIndex
    
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceIndex -in $physicalAdapterIndices}).IPAddress
    
    if ($localIP -ne $null -and $localIP.Count -gt 0) {
        return $localIP
    } else {
        return "No Active Physical Adapter IP"
    }
}


function Get-Hostname {
    return [System.Net.Dns]::GetHostName()
}