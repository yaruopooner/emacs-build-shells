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


function DownloadFromURI( [string]$TaskName, [string]$Uri, [switch]$Expand, [switch]$CreateExpandDirectory, [switch]$Install, [object]$CallbackBeforeExpand = $null )
{
    if ( $Uri.Length -eq 0 )
    {
        Write-Host "invalid URI=$Uri"

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
    $downloaded_file = [System.IO.Path]::GetFileName( $Uri )

    if ( !( Test-Path $downloaded_file ) )
    {
        Write-Host "#downloading : ${uri}"
        # Invoke-WebRequest -Uri $Uri -OutFile $downloaded_file
        Start-BitsTransfer -Source $Uri -Destination $downloaded_file
    }
    else
    {
        Write-Host "#already exist : ${uri}"
    }


    # check same archive file decompress
    $history_log_file = "./${TaskName}.expanded-archive"

    if ( Test-Path -Path $history_log_file -PathType leaf )
    {
        $expanded_file = Get-Content $history_log_file

        if ( $expanded_file -eq $downloaded_file )
        {
            # cancel expand
            $Expand = $false
            Write-Host "#already expanded : ${downloaded_file}"
        }
    }

    # archive expand
    if ( $Expand )
    {
        if ( $CallbackBeforeExpand -ne $null )
        {
            Write-Host "#execute callback before expand"
            . $CallbackBeforeExpand
        }

        $is_expanded = $false

        # zip
        $extension = [System.IO.Path]::GetExtension( $downloaded_file )

        if ( $extension -eq ".zip" )
        {
            $expand_path = [System.IO.Path]::GetFileNameWithoutExtension( $downloaded_file )

            if ( !( Test-Path -Path $expand_path -PathType container ) )
            {
                Write-Host "#expanding : ${downloaded_file}"
                Expand-Archive -Path $downloaded_file -DestinationPath "./" -Force
                $is_expanded = $true
            }
        }

        # 7zip
        $regex = [regex]".+(?<tar>`.tar)(?<compress_type>`.[^.]+)$"
        $regex_result = $regex.Matches( $downloaded_file )

        if ( $regex_result.Count -ne 0 )
        {
            # $archiver = "./7za.exe"
            $archiver = "7za.exe"

            $regex_result | % {
                $is_tar = $_.Groups[ "tar" ].Success
                $extension_index = $_.Groups[ "tar" ].Index
            }
            $regex_result | % {
                $compress_type = $_.Groups[ "compress_type" ].Value
            }
            $expand_path = $downloaded_file.Substring( 0, $extension_index )

            if ( ( Test-Path $archiver ) -and $is_tar )
            {
                if ( !$CreateExpandDirectory -Or !( Test-Path -Path $expand_path -PathType any ) )
                {
                    Write-Host "#expanding : ${downloaded_file}"
                    # & $archiver x $downloaded_file -so | $archiver x -si -ttar -o$expand_path
                    # ↓この渡し方じゃないと実行できない
                    # & cmd.exe /c "$archiver x $downloaded_file -so | $archiver x -si -ttar -o$expand_path"
                    $arguments = "$archiver x $downloaded_file -so | $archiver x -si -ttar"
                    if ( $CreateExpandDirectory )
                    {
                        $arguments = $arguments + "-o$expand_path"
                    }
                    & cmd.exe /c $arguments

                    $is_expanded = $true
                }
            }
        }


        if ( $is_expanded )
        {
            # log
            echo $downloaded_file | Out-File -Encoding ASCII $history_log_file
        }
    }

    # installer execute 
    if ( $Install )
    {
        Start-Process -FilePath $downloaded_file
    }
    
    # popd
}


function CheckAndRemoveOldMsys2()
{
    if ( Test-Path -Path "./msys64" -PathType container )
    {
        Write-Host "#remove old directory : ./msys64"
        # Remove-Item -Path "./msys64" -Recurse -Force
        & cmd.exe /c "rmdir /S /Q .\msys64"
    }
}


function SetupEnvironment()
{
    $uri_7zip = "http://www.7-zip.org/a/7za920.zip"
    $uri_msys2 = $MSYS2_ARCHIVE_URI

    DownloadFromURI -TaskName "7zip" -Uri $uri_7zip -Expand
    DownloadFromURI -TaskName "msys2" -Uri $uri_msys2 -Expand -CallbackBeforeExpand CheckAndRemoveOldMsys2

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
$MSYS2_ARCHIVE_URI="http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20170918.tar.xz"
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

