function Set-Parameters {
    
    <#
		.SYNOPSIS
			Fill in the &parameters& in the provided string
		
		.DESCRIPTION
            This function will fill in all parameters with the specified data, you can also
            call the Graph API for a specific user to recieve his or her data.
		
		.PARAMETER Fill
            The string value that includes the parameters that have to be filled.
            Required for both parameter sets.
        
        .PARAMETER Parameters
            Specify the parameters written in the Fill parameter. These will be filled.
            Required for both parameter sets.
            
        .PARAMETER DefaultParamValue
            Specify default values for the parameters, they will be used if the Data for
            a parameter schould be empty. Optional for both parameter sets

        .PARAMETER Data
            The data that the parameters will be filled with. Required for the manual
            parameter set. Not available in the GraphAPI set.

        .PARAMETER DirectoryID
            Fill in the Directory (tenant) ID provided by the GraphAPI in Azure AD,
            this is a required parameter for the GraphAPI set.
        
        .PARAMETER ApplicationID
            Fill in the Application (client) ID provided by the GraphAPI in Azure AD,
            this is a required parameter for the GraphAPI set.

        .PARAMETER ClientSecret
            Fill in the Client secret you created for the Graph APi in Azure AD,
            this is a required parameter for the GraphAPI set.
            
        .PARAMETER UPN
            You can provide the UPN of a user if you only want to recieve data from
            the specified user for the GraphAPI set.
            
        .PARAMETER Scope
            Change the default scope to a specified scope. Only available in the GraphAPI
            parameterset.
            
        .PARAMETER GrantType
            Change the default GrantType value from client_credentials to what you specify. 
            Only available in the GraphAPI parameterset.

        .EXAMPLE
            Manual parameter set:
			PS C:\> Set-Parameters -Fill 'this &mail&' -Data $MailData -Parameters 'mail'
            FIll the mail parameter with mail data.
            
            GraphAPI parameter set:
            PS C:\> Set-Parameters -Fill 'this &mail&' -Parameters 'mail' -directoryID 'DIRE-CTOR-YID0' -applicationID 'APPL-ICAT-IONI-D001' -ClientSecret 'Sk91n98#' -UPN 'twan.duvigneau@it-value.nl'
            FIll the mail parameter with data recieved from the GraphAPI of the specified user.
		
        .NOTES
            Two parametersets are used, manual and GraphAPI. The manuel set is default.
			Author: Twan Duvigneau
	#>

    [CmdletBinding(
        DefaultParameterSetName='Manual'
    )]
    [OutputType([String])]
    Param(   
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeLine =$true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Fill,

        [Parameter(
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [String[]]
        [Array]
        $Parameters,

        [Parameter(
            Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
        [Object]
        $DefaultParamData = $false,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="Manual"
        )]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Data,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="GraphAPI"
        )]
		[ValidateNotNullOrEmpty()]
		[String]
        $DirectoryID,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="GraphAPI"
        )]
		[ValidateNotNullOrEmpty()]
		[String]
        $ApplicationID,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="GraphAPI"
        )]
		[ValidateNotNullOrEmpty()]
		[String]
        $ClientSecret,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="GraphAPI"
        )]
        [ValidateNotNullOrEmpty()]
		[String]
        $UPN,

        [Parameter(
            Mandatory=$false,
            ParameterSetName="GraphAPI"
        )]
        [ValidateNotNullOrEmpty()]
		[String]
        $Scope = 'https://graph.microsoft.com/.default',
        
        [Parameter(
            Mandatory=$false,
            ParameterSetName="GraphAPI"
        )]
        [ValidateNotNullOrEmpty()]
		[String]
		$GrantType = 'client_credentials'

    )

    begin 
    {
        If ($PSCmdlet.ParameterSetName -eq 'GraphAPI') {

            $graphRequest = @{
                DirectoryID   = $DirectoryID
                ApplicationID = $ApplicationID
                ClientSecret  = $ClientSecret
                UserData      = $Parameters
                UPN           = $UPN
                Scope         = $Scope 
                GrantType     = $GrantType
            }
            
            $Data = Invoke-GraphRequest @graphRequest
            
        }

    }

    process
    {   
        ForEach ($param in $Parameters) { 
            
            If ($DefaultParamData) {
                
                If ($Data.$param -eq '' -or $null -eq $Data.$param) {

                    $Data.$param = $DefaultParamData.$param

                }

            }
                
            $Fill = $Fill -replace "&$($param)&", ($Data.$param)

        }
        
        Return $Fill
    }
}