Function Invoke-GraphRequest {
	<#
		.SYNOPSIS
			Invokes a call to the Graph API from Microsoft.
		
		.DESCRIPTION
            This function will invoke a get call to the Graph API from Microsoft
            to recieve data from the users.
		
		.PARAMETER DirectoryID
            Fill in the Directory (tenant) ID provided by the GraphAPI in Azure AD,
            this is a required parameter.
        
        .PARAMETER ApplicationID
            Fill in the Application (client) ID provided by the GraphAPI in Azure AD,
            this is a required parameter.

        .PARAMETER ClientSecret
            Fill in the Client secret you created for the Graph APi in Azure AD,
            this is a required parameter.
            
        .PARAMETER UserData
            You can provide a specific list/array of UserData you want to recieve,
            like displayName, jobTitle or mail.

        .PARAMETER FDN
            You can provide the FDN of a user if you only want to recieve data from
            the specified user.
            
        .PARAMETER Scope
            Change the default scope to a specified scope.
            
        .PARAMETER GrantType
            Change the default GrantType value from client_credentials to what you specify.  
        
		.EXAMPLE
			PS C:\> Invoke-GraphRequest -DirectoryID 'dire-ctor-yid0' -ApplicationID 'appl-icat-ioni-d000 -ClientSecret '.?ASIOJ#LkA'  
			Retrieves all UserData from the GraphAPI of the specified Directory ID.
		
		.NOTES
            Paging of the API is automatically retrieved as well.
            Author: Twan Duvigneau
	#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(
			Mandatory=$true
        )]
		[ValidateNotNullOrEmpty()]
		[String]
        $DirectoryID,
        
        [Parameter(
			Mandatory=$true
        )]
		[ValidateNotNullOrEmpty()]
		[String]
        $ApplicationID,

        [Parameter(
			Mandatory=$true
        )]
		[ValidateNotNullOrEmpty()]
		[String]
        $ClientSecret,

        [Parameter(
			Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
        [String[]]
        [Array]
        $UserData,

        [Parameter(
			Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
		[String]
        $UPN,

        [Parameter(
			Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
		[String]
        $Scope = 'https://graph.microsoft.com/.default',
        
        [Parameter(
			Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
		[String]
		$GrantType = 'client_credentials'
	)

	begin 
	{
		$graphTokenCall = @{
            method          = 'Post'
            uri             = "https://login.microsoftonline.com/$($DirectoryID)/oauth2/v2.0/token"
            contentType     = 'application/x-www-form-urlencoded'
            useBasicParsing = $true
            body            = @{
                client_id     = $ApplicationID
                scope         = $Scope
                client_secret = $ClientSecret
                grant_type    = $GrantType
            }
        }

        $graphDataCall = @{
            method      = 'Get'
            uri         = "https://graph.microsoft.com/v1.0/users/$($UPN)?`$select=$(($UserData -join ','))"
            contentType = 'application/json'
            Headers     = @{
                Authorization = $null
            }
        }
	}

	process
	{
        $graphToken = ((Invoke-WebRequest @graphTokenCall).content | ConvertFrom-Json).access_token
        
        $graphDataCall.headers.Authorization = "Bearer $($graphToken)"

        $graphCallRaw = Invoke-RestMethod @graphDataCall

        If ($graphCallRaw.'@odata.nextLink') {
            $graphData = $graphCallRaw.value

            $graphCallNextLink = $graphCallRaw.'@odata.nextLink'

            While ($graphCallNextLink) {
                
                $graphDataCall.uri = $graphCallNextLink
            
                $GraphCallRaw = Invoke-RestMethod @graphDataCall
            
                $graphData += $graphCallRaw.value
            
                $graphCallNextLink = $GraphCallRaw.'@odata.nextLink'
            }

        } else {

            $graphData = $graphCallRaw 

        }

        return $graphData
	}
}