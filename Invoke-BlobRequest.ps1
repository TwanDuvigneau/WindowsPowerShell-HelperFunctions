Function Invoke-BlobRequest {
	<#
		.SYNOPSIS
			Download blob item from blob.
		
		.DESCRIPTION
            This function will invoke the DownloadFile command to the System.Net.WebClient
            to download a specific file from the blob storage.
		
		.PARAMETER DownloadLocation
            Fill in the full parth to the download location including file name + extension.
            Only required if the file has to be downloaded. Set: Download.
        
        .PARAMETER BlobUrl
            Fill in the URl to the blob storage where the requested file is present.
            Required in all sets.
        
        .PARAMETER BlobSas
            Fill in the SAS required to access the files on the specified blob.
            Required in all sets.
        
        .PARAMETER Read
            If the read flag is called the file will not be downloaded from the blob, but read.
            Set: Read.

        .PARAMETER GetContent
            If the GetContent flag is called the content of the downloaded file will be returned.
            Set: Download.

        .PARAMETER File
            Fill in the file name + extension if you only want to read a file from the blob.
            Required if Read flag is used. Set: Read.
        
		.EXAMPLE
			PS C:\> Get-BlobItem -DownloadLocation 'C:\Example.txt' -BlobURL 'https://itvalue.blob.core.windows.net/blob' -BlobSAS '?svni201803982'
			Downloades the Example.txt file from the blobcontainer.
		
        .NOTES
            The filename + extension in -DownloadLocation will be used to create full 
            URL to the file on the internet.
			Author: Twan Duvigneau
	#>
	
	[CmdletBinding(
        DefaultParameterSetName='Download'
    )]
	param
	(
		[Parameter(
            Mandatory=$true,
            ParameterSetName='Download'
        )]
        [ValidateNotNullOrEmpty()]
        [string] 
        $DownloadLocation,
        
        [Parameter(
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [string] 
        $BlobUrl,

        [Parameter(
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [string] 
        $BlobSas,

        [Parameter(
            Mandatory=$true,
            ParameterSetName='Read'
        )]
        [ValidateNotNullOrEmpty()]
        [string] 
        $File = (Split-Path $downloadLocation -Leaf),

        [Parameter(
            Mandatory=$true,
            ParameterSetName='Read'
        )]
        [switch] 
        $Read = $false,

        [Parameter(
            Mandatory=$false,
            ParameterSetName='Download'
        )]
        [switch] 
        $GetContent = $false

	)

	begin 
	{
        $downloadURL = "$($BlobUrl)/$($File)$($BlobSas)"
	}

	process
	{
        if ($PSCmdlet.ParameterSetName -eq 'Download') {

            if (Test-Path $downloadLocation) {

                Remove-Item -Path $downloadLocation -Force
        
            }
    
            if (!(Test-Path (Split-Path $downloadLocation))) {
    
                New-Item (Split-Path $downloadLocation) -ItemType Directory
        
            }
            
            (New-Object System.Net.WebClient).DownloadFile($downloadURL, $downloadLocation)

            if($GetContent) {

                Return Get-Content $downloadLocation
    
            }

        }

        if ($Read) {

            Return (Invoke-WebRequest -Uri $downloadURL -UseBasicParsing).Content

        } 
	}
}