Function Set-Registry {

    <#
        .SYNOPSIS
            This function gives you the ability to create/change Windows registry keys and values. 
            If you want to create a value but the key doesn't exist, it will create the key for you.
            If a value already exists it will not be altered, this can be overwritten with the -Force flag.

		.DESCRIPTION
            This function will create or edit registry keys
		
		.PARAMETER Key
            Fill in the path to the registry key you want to create/edit
        
        .PARAMETER ValueName
            Fill in the name of the registry entry to create/edit
        
        .PARAMETER ValueData
            Fill in the data you want to fill the registry key with
        
        .PARAMETER Type
            Fill in which type of registry key you want to create, option are:
            String, DWord, Binary, ExpandString, MultiString, QWord.

        .PARAMETER Force
            The force flag will force the creation or edit of the specified key

		.EXAMPLE
			PS C:\> Get-BlobItem -DownloadLocation 'C:\Example.txt' -BlobURL 'https://itvalue.blob.core.windows.net/blob' -BlobSAS '?svni201803982'
			Downloades the Example.txt file from the blobcontainer.
		
        .NOTES
            Author: Dominik Britz.
            Source: https://github.com/DominikBritz
	#>

    [CmdletBinding(DefaultParameterSetName = 'Key')]
    param(
        [parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Key,

        [parameter(
            Mandatory = $true,
            ParameterSetName = 'ValueSet'
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $ValueName,
        
        [parameter(
            Mandatory = $true,
            ParameterSetName = 'ValueSet'
            
        )]
        [ValidateNotNullOrEmpty()]
        [Object]
        $ValueData,
        
        [parameter(
            Mandatory = $false,
            ParameterSetName = 'ValueSet'
        )]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Win32.RegistryValueKind]
        $Type,

        [parameter(
            Mandatory = $false,
            ParameterSetName = 'ValueSet'
        )]
        [Switch]
        $Force = $False
    )

    begin 
	{
        if ($PSCmdlet.ParameterSetName -ne 'ValueSet') {

            $Force = $True
    
        }
    }

    process
	{
        if (-not (Test-Path $Key)) {

            New-Item -Path $Key -Force:$Force
        
        }
    
        if ($PSCmdlet.ParameterSetName -eq 'ValueSet') {
    
            Set-ItemProperty -Path $Key -Name $ValueName -Value $ValueData -Type $Type -Force:$Force

    
        }  
    }
}