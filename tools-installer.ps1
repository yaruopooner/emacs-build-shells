



function DownloadFromURI( $uri, [switch]$expand, [switch]$forceExpand, [switch]$install )
{
    # directory check
    $download_directory = "./tools-latest-version/"

    if ( !( Test-Path $download_directory ) )
    {
        New-Item -Name $download_directory -Type directory
    }

    pushd $download_directory

    # download
    $downloaded_file = [System.IO.Path]::GetFileName( $uri )

    if ( !( Test-Path $downloaded_file ) )
    {
        Write-Host "#downloading : " + $uri
        Invoke-WebRequest -Uri $uri -OutFile $downloaded_file
    }
    else
    {
        Write-Host "#already exist : " + $uri
    }
    

    # archive expand
    if ( $expand )
    {
        $extension = [System.IO.Path]::GetExtension( $downloaded_file )
        if ( ( $extension -eq ".zip" ) -or $forceExpand )
        {
            $expanded_path = [System.IO.Path]::GetFileNameWithoutExtension( $downloaded_file )

            if ( !( Test-Path -Path $expanded_path -PathType container ) )
            {
                Write-Host "#expanding : " + $downloaded_file
                Expand-Archive -Path $downloaded_file -DestinationPath "./" -Force
            }
        }
    }

    # installer execute 
    if ( $install )
    {
        Start-Process -FilePath $downloaded_file
    }
    
    popd
}



function SetupEnvironment()
{
    
    $uri_msys2 = "http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20160921.tar.xz"

    DownloadFromURI -Uri $uri_msys2 -Expand
}


setupEnvironment

[Console]::ReadKey()

