Function Get-UPN {
	
	<#
		.SYNOPSIS
			Recieve the UPN of the current user.
		
		.DESCRIPTION
            This function will recieve the UPN of the current user. Multiple methods 
            provided.
		
		.PARAMETER UserDomain
			The string value that will be converted to bytes.
        
        .PARAMETER Method
            Specify the method you want to use to recieve the current users UPN.
            Default methods is Outlook, all methods are:
            Outlook, LoggedOnUser

		.EXAMPLE
			PS C:\> Get-UPN -UserDomain 'IT-Value.nl'
			Converts the string to Base64 using the ASCII codec.
		
		.NOTES
            Only use LoggedOnUser if UPN is equal to the primary mail adress in you're AD.
			Author: Twan Duvigneau
	#>
	
	[CmdletBinding()]
	[OutputType([System.String])]
	param
	(
		[Parameter(
			Mandatory=$true
        )]
		[ValidateNotNullOrEmpty()]
		[String]
		$UserDomain,

		[Parameter(
			Mandatory=$false
		)]
        [ValidateSet('Outlook', 'LoggedOnUser')]
        [ValidateNotNullOrEmpty()]
		[String]
        $Method = 'Outlook'
	)

	process
	{
        If ($Method -eq 'Outlook') {

            $UPN = (Get-ItemProperty "hkcu:\Software\Microsoft\Office\16.0\Outlook\Profiles\Outlook\9375CFF0413111d3B88A00104B2A6676\*" | Where-Object {
        
                $_.'Account Name' -match "@$($UserDomain)" -or $_.'Account Name' -match "@$(([io.path]::GetFileNameWithoutExtension($UserDomain)) -replace '[\W]', '').onmicrosoft.com"
                
            } ).'Account name'  

        }

        ElseIf ($Method -eq 'LoggedOnUser') {

            $remove = (([io.path]::GetFileNameWithoutExtension($UserDomain)) -replace '[\W]', '').length + 1

            $userName = (whoami).substring($remove)
            
            $UPN = "$($userName)@$($UserDomain)"

        }

        Return $UPN
	}
}