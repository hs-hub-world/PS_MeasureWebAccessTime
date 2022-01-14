param(
    $Proxy="",#Leave it blank to skip proxy
    $TestSites = "http://msnbc.com,http://google.com,http://yahoo.com",
    $NumberOfTimesTestEachSite = 2,
    $SecToWaitBetweenEachSite = 3
)

if($Proxy -and ![string]::IsNullOrEmpty($Proxy))
{
    write "Using Proxy"
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value "$($Proxy):80";
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 1;    
}
else
{
    write "No Proxy Assigned (skipping proxy use)."
}



$Results = @()

foreach($SiteUrl in $TestSites.Split(","))
{
    $SiteRes = "" |select Host,Site,TestTime,Avg,Max,Min
    write-host "Testing:$($SiteUrl)"
    $SiteRes.Site=$SiteUrl
    $Res = foreach($i in 1..$NumberOfTimesTestEachSite)
    {  
     (Measure-Command -Expression { $site = Invoke-WebRequest -Uri $SiteUrl -UseBasicParsing }).TotalMilliseconds
     sleep 1
    }

    $SiteMeasure = $Res | Measure-Object -Average -Minimum -Maximum
    $SiteRes.Avg = $SiteMeasure.Average.ToString("##0,0ms")
    $SiteRes.Max = $SiteMeasure.Average.ToString("##0,0ms")
    $SiteRes.Min = $SiteMeasure.Minimum.ToString("##0,0ms")
    $SiteRes.TestTime = (Get-Date).ToString("MM/dd/yyyy hh:mm:ss")
    $SiteRes.Host = hostname

    $Results +=$SiteRes
    sleep $SecToWaitBetweenEachSite
}

write "-----------------------------------"
$Results |FT
