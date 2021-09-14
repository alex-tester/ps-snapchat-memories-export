<#       <------------ THIS STARTS A NEW COMMENT BLOCK
Author: Alejandro Estrete
Date  : 2021.09-14
#>       



#we'll uniquely name our result file using current date - save for later
$currDtPath = (Get-Date).ToString('yyyyMMdd')
#duh
$accountName = "aletes010"
#output path to save our archive to
$outputPath = ("C:\temp\Snapchat_$currDtPath" + $accountName + ".zip")

#this is the url you get from the email. it expires after 
#like ten mins or something and you need to reopen the link from the email to get a new download link

$tempSnapUri = "<ENTER THE URL YOU RECEIVED WHEN VISITING THE LINK FROM YOUR EMAIL>"




#ask web server for file
Invoke-WebRequest  -uri $tempSnapUri -OutFile $outputPath -Method Get 

#verify existence of downloaded file
$fileExists = Test-Path $outputPath #returns bool

#execute if condition is true
if ($fileExists)
{
    #cant remember unzip command
    #help *archive*
    
    #extract the files
    #but make the dir structure first
    $extractPath = $outputPath -replace ".zip","\"
    $extractPathExists = Test-Path $extractPath
    
    
    #if extractpathexists is false, then execute
    if (-not $extractPathExists)
    {
        New-Item -Path $extractPath -ItemType Directory -Confirm:$false

    }
    else
    {

    }
    Expand-Archive "$outputPath" -DestinationPath "$extractPath"


}

$memoriesJson = Get-Content ($extractPath + "json\memories_history.json")
$memoriesObj = $memoriesJson | ConvertFrom-Json

$dlLinks = $memoriesObj.'Saved Media'.'Download Link'


$dlLinkCount = $dlLinks.Count

$i = 0

Write-Host "You have $($dlLinkCount) items saved in your memories" -BackgroundColor Black -ForegroundColor Green

$activityString = "Saving all memories from Snapchat"
foreach ($dl in $dlLinks)
{
    
    $i++
    #calculate the current percent complete
    $statusString = "Saving item $i out of $dlLinkCount for user: $accountName"
    
    $percent = $i / $dlLinkCount * 100
    
    Write-Progress -Activity $activityString -Status $statusString -PercentComplete $percent -Id 1


    Clear-Variable -Name finalDlLink
     $finalDlLink = Invoke-RestMethod -Method Post -Uri $dl -Headers $headers
    #$secondMemRequest = Invoke-WebRequest -Uri $downloadUrlParts[0] -Method Post -Headers $headers -SessionVariable sesh -Body $downloadUrlParts1 # -WebSession $sesh
         $itemNameSplit = ($finalDlLink -split "\?")[0].Split(".")
         $itemNameFileTypeIndex = ($itemNameSplit.Count - 1)
         $itemNameFileNameIndex = ($itemNameSplit.Count - 2)
         $itemFileType = $itemNameSplit[$itemNameFileTypeIndex]
         #$itemFileNameOutput = $extractPath + $itemNameSplit[$itemNameFileNameIndex] + "." + $itemNameSplit[$itemNameFileTypeIndex]
         $itemFileNameOutput = $extractPath + $i.ToString() + "." + $itemFileType
         $itemFileType

    Invoke-RestMethod -Method Get -Uri $finalDlLink -Headers $headers -outfile $itemFileNameOutput

}








<#
#get web page saved locally
$index = Invoke-WebRequest -Uri ($extractPath + "index.html") -Method Get -UseBasicParsing

#did some digging to find the usable urls for memories
$memoriesMainLink = $extractPath + "html\memories_history.html"
$memories = Invoke-WebRequest $memoriesMainLink

$indexLineByLine = $index.RawContent -split "<br/>"
#$memoriesLineByLine = $memories.RawContent -split "<br/>" -split ";>download"
#>

<# JAVASCRIPT CODE STOLEN FROM SNAPCHAT

function downloadMemories(url) {
                    var parts = url.split("?");
                    var xhttp = new XMLHttpRequest();
                    xhttp.open("POST", parts[0], true);
                    xhttp.onreadystatechange = function() {
                        if (xhttp.readyState == 4 && xhttp.status == 200) {
                            var a = document.createElement("a");
                            a.href = xhttp.responseText;
                            a.style.display = "none";
                            document.body.appendChild(a);
                            a.click();
                            document.getElementById("mem-info-bar").innerText = "";
                        } else if (xhttp.readyState == 4 && xhttp.status >= 400) {
                            document.getElementById("mem-info-bar").innerText = "Oops!                 Something went wrong. Status " + xhttp.status
                        }
                    }
                    ;
                    xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                    xhttp.send(parts[1]);
                }

                #>
<#

$memoriesUriStringPrefix = '<a href="javascript:downloadMemories'

$memoriesLineByLine = ($memories -split "$memoriesUriStringPrefix")
#>

<# THIS SHIT SUCKS
$i = 0
foreach ($m in $memoriesLineByLine)
{
    
    $i++
   #if ($m -contains "https")
   #{
        $m
        $downloadUrl = $m -replace "\(\'","" -replace "\'\);" 
        $downloadurl = $downloadUrl -replace "\`">download</a></td></tr></tbody></table></div></body></html>",""
        $downloadUrl = $downloadUrl -replace "`">download</a></td></tr><tr><td>2021-08-28 13:35:24 UTC</td><td>PHOTO</td><td>",""
        $downloadUrlParts = $downloadUrl -split "\?"
        $headers =  @{
        'Content-type' = "application/x-www-form-urlencoded"
       }
       if ($downloadUrl.StartsWith("http"))
       {
            $initMemRequest = Invoke-WebRequest -Uri $downloadUrl -Method Post -Headers $headers -Body $downloadUrlParts[1] # -OutFile ($extractPath + "$i.tostring()")

            #the url to the actual file resides in the response to this initial request.
            $realItemUri = $initMemRequest.Content
            $realItemUri






    

         #$secondMemRequest = Invoke-WebRequest -Uri $downloadUrlParts[0] -Method Post -Headers $headers -SessionVariable sesh -Body $downloadUrlParts1 # -WebSession $sesh
         $itemNameSplit = ($realItemUri -split "\?")[0].Split(".").Split("\/")
         $itemNameFileTypeIndex = ($itemNameSplit.Count - 1)
         $itemNameFileNameIndex = ($itemNameSplit.Count - 2)
         $itemFileType = $itemNameSplit[$itemNameFileTypeIndex]
         #$itemFileNameOutput = $extractPath + $itemNameSplit[$itemNameFileNameIndex] + "." + $itemNameSplit[$itemNameFileTypeIndex]
         $itemFileNameOutput = $extractPath + $i.ToString() + "." + $itemFileType

         Invoke-WebRequest -Uri $realItemUri -Headers $headers -Method Get -OutFile $itemFileNameOutput

         #Invoke-WebRequst -Uri ($downloadUrl) -Method Post -Body $downloadUrlParts[1] -Headers $headers -OutFile $itemFileNameOutput
         #Invoke-WebRequest -Uri $downloadUrl -Method Post -Headers $headers -Body $downloadUrlParts[1] -OutFile $itemFileNameOutput
         #Invoke-WebRequest -Uri ($downloadUrl) -OutFile $itemFileNameOutput 
  
   }

}


#ask not what your variable can do for you, ask what you can do for your variable
$index | Get-Member
#>
