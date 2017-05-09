# -*- mode: powershell ; coding: utf-8-dos -*-


function updateFileItem( [string]$source, [string]$destination )
{
    if ( Test-Path -Path $destination -PathType leaf )
    {
        # already exist
        $src_time = ( Get-ItemProperty -Path $source ).LastWriteTime.Ticks
        $dest_time = ( Get-ItemProperty -Path $destination ).LastWriteTime.Ticks

        if ( $src_time -gt $dest_time )
        {
            # overwrite copy
            Copy-Item -Path $source -Destination $destination -Force
            Write-Host " Overwrite File : " $source
        }
        else
        {
            # skip
            Write-Host " Skip File : " $source
        }
        }
    else
    {
        # copy
        Copy-Item -Path $source -Destination $destination
        Write-Host " Copy File : " $source
    }
}


function updateItem( [string]$source, [string]$destination )
{
    if ( Test-Path -Path $source -PathType container )
    {
        # directory
        Write-Host "Update Directory Item : ${source} ==> ${destination}"

        if ( !( Test-Path -Path $destination -PathType container ) )
        {
            New-Item -Name $destination -Type directory
        }

        Get-ChildItem $source -Recurse | % {
            $dest_file_apath = Join-Path $destination $_.Name

            updateItem -source $_.FullName -destination $dest_file_apath
        }
    }
    else
    {
        # file
        Write-Host "Update File Item : ${source} ==> ${destination}"

        updateFileItem -source $source -destination $destination
    }
}


function DownloadFromURI( [string]$uri, [switch]$expand, [switch]$install )
{
    if ( $uri.Length -eq 0 )
    {
        Write-Host "invalid URI=$uri"

        return
    }

    # directory check
    # $download_directory = "./tools-latest-version/"

    # if ( !( Test-Path $download_directory ) )
    # {
    #     New-Item -Name $download_directory -Type directory
    # }

    # pushd $download_directory

    # download
    $downloaded_file = [System.IO.Path]::GetFileName( $uri )

    if ( !( Test-Path $downloaded_file ) )
    {
        Write-Host "#downloading : ${uri}"
        # Invoke-WebRequest -Uri $uri -OutFile $downloaded_file
        Start-BitsTransfer -Source $uri -Destination $downloaded_file
    }
    else
    {
        Write-Host "#already exist : ${uri}"
    }
    

    # archive expand
    if ( $expand )
    {
        $extension = [System.IO.Path]::GetExtension( $downloaded_file )
        $expanded_path = [System.IO.Path]::GetFileNameWithoutExtension( $downloaded_file )

        if ( $extension -eq ".zip" )
        {
            if ( !( Test-Path -Path $expanded_path -PathType container ) )
            {
                Write-Host "#expanding : ${downloaded_file}"
                Expand-Archive -Path $downloaded_file -DestinationPath "./" -Force
            }
        }
        $cmd = "./7za.exe"
        if ( ( ( $extension -eq ".xz" ) -or ( $extension -eq ".gz" ) ) -and ( Test-Path $cmd ) )
        {
            if ( !( Test-Path -Path $expanded_path -PathType any ) )
            {
                Write-Host "#expanding : ${downloaded_file}"
                & $cmd x $downloaded_file -aos
            }

            $extension2 = [System.IO.Path]::GetExtension( $expanded_path )
            if ( $extension2 -eq ".tar" )
            {
                $extract_name = [System.IO.Path]::GetFileNameWithoutExtension( $expanded_path )
                if ( !( Test-Path -Path $extract_name -PathType any ) )
                {
                    & $cmd x $expanded_path -aos
                }
            }
        }
    }

    # installer execute 
    if ( $install )
    {
        Start-Process -FilePath $downloaded_file
    }
    
    # popd
}



function SetupEnvironment()
{
    $uri_7zip = "http://www.7-zip.org/a/7za920.zip"
    $uri_msys2 = $MSYS2_ARCHIVE_URI

    DownloadFromURI -Uri $uri_7zip -Expand
    if ( !( Test-Path -Path "./msys64" -PathType container ) )
    {
        DownloadFromURI -Uri $uri_msys2 -Expand
    }

    if ( Test-Path -Path "./msys64" -PathType container )
    {
        $tmp_dir = "msys64/tmp"
        updateItem -source "build-shells" -destination "${tmp_dir}/build-shells"

        Write-Host $HOME

        pushd msys64

        $cmd = "./${MSYS2_LAUNCH_SHELL}"
        & $cmd
        popd
    }
}



# preset vars
$MSYS2_ARCHIVE_URI="http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20160921.tar.xz"
$MSYS2_LAUNCH_SHELL="mingw64.exe"

# overwrite vars load
$INSTALL_MSYS2_OPTIONS_FILE="install-msys2.ps1.options"
$INSTALL_MSYS2_OPTIONS_SRC_FILE="${INSTALL_MSYS2_OPTIONS_FILE}.sample"

updateItem -source "./${INSTALL_MSYS2_OPTIONS_SRC_FILE}" -destination "./${INSTALL_MSYS2_OPTIONS_FILE}"
if ( Test-Path -Path "./${INSTALL_MSYS2_OPTIONS_FILE}" -PathType leaf )
{
    Get-Content "./${INSTALL_MSYS2_OPTIONS_FILE}" -Raw | Invoke-Expression
}


setupEnvironment

[Console]::ReadKey()

