function Invoke-AzureLog {
    
    <#
		.SYNOPSIS
			Write JSON log to Azure.
		
		.DESCRIPTION
            This function will send a JSON log to the specified Workspace in Azure.
		
		.PARAMETER Log
			The log that needs to be posted to Azure.

        .PARAMETER Key
            The key to the Workspace where the Azure log has to be posten, can be
            primary or secondary key.

        .PARAMETER WorkspaceID
            The WorkspaceID to where the Azure log will be written.

        .PARAMETER EntryName
            Name of the Entry in the Workspace to where the log has to be written.
            _CL will be added to the name in Azure automatically.

        .PARAMETER Date
            The date the log was created in the right format for JSON, this 
            parameter is not required. If not set it will generate date.
        
        .PARAMETER ConverttoJSON
            By calling the ConverttoJSON flag the value in the Log parameter will
            convert to JSON before being posted.

		.EXAMPLE
			PS C:\> Invoke-AzureLog -log $JSONLog -key 'ISLNBDS83D' -WorkspaceID 'WORK-SPAC-ID01' -EntryName 'TestLog'
			Posts log to Azure.
		
		.NOTES
			Author: Twan Duvigneau
	#>

    [CmdletBinding()]
    Param(   
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeLine =$true
        )]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Log,

        [Parameter(
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Key,

        [Parameter(
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $WorkspaceID,

        [Parameter(
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $EntryName,

        [Parameter(
            Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
        $Date,

        [Parameter(
			Mandatory=$false
		)]
		[Switch]
        $ConverttoJSON = $false
    )

    begin 
    {
        $postAzureLog = @{
            Method          = "POST"
            Uri             = "https://$($workspaceID).ods.opinsights.azure.com/api/logs?api-version=2016-04-01"
            ContentType     = "application/json" 
            body            = $null
            UseBasicParsing = $true
            Headers         = @{
                "Authorization" = $null
                "Log-Type"      = $EntryName
                "x-ms-date"     = $Date
            }
        }
    }

    process
    {   
        If ($converttoJSON) {

            $Log = ConvertTo-Json $Log -Compress

        }

        $postAzureLog.body = [System.Text.Encoding]::UTF8.GetBytes($Log)

        $autorizationHeader = 'POST' + "`n" + $postAzureLog.body.length + "`n" + 'application/json' + "`n" + "x-ms-date:" + $date + "`n" + "/api/logs"

        $base64ForHash = [Text.Encoding]::UTF8.GetBytes($autorizationHeader) 

        $sha256 = New-Object System.Security.Cryptography.HMACSHA256

        $sha256.Key = [Convert]::FromBase64String($key)

        $encodedHash = [Convert]::ToBase64String($sha256.ComputeHash($base64ForHash))

        $postAzureLog.Headers.Authorization = 'SharedKey {0}:{1}' -f $workspaceID,$encodedHash

        return Invoke-WebRequest @postAzureLog

    }
}
