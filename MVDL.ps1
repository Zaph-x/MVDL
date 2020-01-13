Import-Module -Name Selenium


$moodleBaseUrl = "https://www.moodle.aau.dk"
$moodleLoginUrl = "https://www.moodle.aau.dk/login"
$moodleCourseUrl = "https://www.moodle.aau.dk/course/view.php?id=31429"

$username = Read-Host -Prompt "Enter your username: "
$password = Read-Host -Prompt "Enter your password: "
$i = 1


function DownloadVideosOnPage {
    param (
        $url
    )
    $videos = @()
    Find-SeElement -TagName a -Driver $Driver | Where-Object {$_.GetAttribute("href") -like "$moodleBaseUrl*.mp4"} | ForEach-Object {
        $videos += $_.GetAttribute("href")
    }

    foreach ($video in $videos) {
        DownloadFromUrl $video $url
    }
    
}


function DownloadFromUrl {
    param (
        $url,
        $returnAddress
    )
    Enter-SeUrl -Driver $Driver -Url $url
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    [System.Windows.Forms.SendKeys]::SendWait("^{s}")
    Start-Sleep -Seconds 4
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Seconds 2

}


function DownloadFromPage {
    param (
        $url
    )
    Enter-SeUrl -Driver $Driver -Url $url
    $pageAnchors = Find-SeElement -Driver $Driver -TagName a | Where-Object {$_.GetAttribute("href") -match "$($moodleBaseUrl)/mod/page/view\.php\?id=\d+$"}
    $anchors = @()

    foreach ($anchor in $pageAnchors) {
        $anchors += $anchor.GetAttribute("href")
    }

    foreach ($link in $anchors) {
        if ($link -notlike $url) {
            DownloadFromPage $link
        }
    }
    DownloadVideosOnPage $url
}



$Driver = Start-SeChrome -DisableBuiltInPDFViewer $true -HideVersionHint
$window = Get-SeWindow -Driver $Driver

if ($Driver) {
    
    Enter-SeUrl -Driver $Driver -Url $moodleLoginUrl
    
    $emailField = Find-SeElement -Id "username" -Driver $Driver 
   
    Send-SeKeys -Element $emailField -Keys "$($username)@student.aau.dk"
    $pwField = Find-SeElement -Id "password" -Driver $Driver
    Send-SeKeys -Element $pwField -Keys $password
    Send-SeKeys -Element $pwField -Keys ([OpenQA.Selenium.Keys]::Enter)

    Enter-SeUrl -Driver $Driver -Url $moodleCourseUrl
    
    DownloadVideosOnPage $moodleCourseUrl
    DownloadFromPage $moodleCourseUrl
    
  

    Stop-SeDriver -Driver $Driver


}
    