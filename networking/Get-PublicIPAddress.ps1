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

Get-PublicIPAddress