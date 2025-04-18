#!/bin/env -S pwsh -NoProfile
param (
    [switch]
    $SkipDownload,
    [switch]
    $GetIMGs,
    [switch]
    $GetRMDs,
    [switch]
    $GetWin10,
    [switch]
    $GetWin11
)

$ISOs = @()
$temp = [system.io.path]::GetTempPath().TrimEnd('\')
if (!($isLinux)) {
    $latestaria2Release = Invoke-WebRequest https://github.com/aria2/aria2/releases/latest -Headers @{"Accept" = "application/json" }
    $aria2json = $latestaria2Release.Content | ConvertFrom-Json
    $latestaria2Version = $aria2json.tag_name
    $VersionNumber = $latestaria2Version -split "-" | Select-Object -Last 1
    Invoke-WebRequest "https://github.com/aria2/aria2/releases/download/$latestaria2Version/aria2-$VersionNumber-win-64bit-build1.zip" -OutFile "$temp/aria2.zip"
    Expand-Archive $temp\aria2.zip -DestinationPath $temp
    $aria2_dir = ("$temp\aria2-*\" | Resolve-Path).Path
}
if ($GetWin10 -or $GetWin11) {
    Invoke-WebRequest "https://github.com/ave9858/Fido/archive/refs/heads/master.zip" -OutFile "$temp/fido.zip"
    Expand-Archive $temp/fido.zip -DestinationPath $temp
    $fido_dir = ("$temp\Fido-*\" | Resolve-Path).Path

    if ($isWindows) {
        $powershell = "powershell"
    } else {
        $powershell = "pwsh"
    } 
}

try {
    # Ubuntu ISOs
    $ubuntu = Invoke-WebRequest "http://cdimage.ubuntu.com/ubuntu/releases/"
    $kubuntu = Invoke-WebRequest "https://cdimage.ubuntu.com/kubuntu/releases/"
    $mate = Invoke-WebRequest "http://cdimage.ubuntu.com/ubuntu-mate/releases/"

    # Arch ISOs
    $Arch = Invoke-WebRequest "https://www.archlinux.org/download/"
    $Artix = Invoke-WebRequest "https://iso.artixlinux.org/isos.php"

    # Other ISOs
    $MXLinux = Invoke-WebRequest "https://mxlinux.org/download-links/"
    $tails = Invoke-WebRequest "https://tails.boum.org/torrents/files/"
    $zorin = Invoke-WebRequest "https://distro.ibiblio.org/zorinos/"
    $void = Invoke-WebRequest "https://repo-default.voidlinux.org/live/current/"

    # Fedora Atomic
    $Silverblue = Invoke-WebRequest "https://torrent.fedoraproject.org/"
    $Kinoite = $Silverblue

    # Manjaro
    $Manjaro = Invoke-WebRequest "https://manjaro.org/products/download/x86"

    # EndeavorOS
    $Endeavor = Invoke-WebRequest "https://endeavouros.com/latest-release/"

    # Gentoo
    $Gentoo = Invoke-WebRequest "https://www.gentoo.org/downloads/"

    # FreeBSD
    $FreeBSD = Invoke-WebRequest "https://download.freebsd.org/ftp/releases/amd64/amd64/"

    if ($GetIMGs -or $GetRMDs) {
        $ChromeOS = Invoke-WebRequest "https://dl.google.com/dl/edgedl/chromeos/recovery/cloudready_recovery.json" | ConvertFrom-Json

        $ChromeOSdir = "Installation-Discs"
        $latestChromeOS = $ChromeOS.url
        $latestChromeOSIMG = $ChromeOS.file -replace ".bin", ".img"
        $oldIMG = (Get-ChildItem $ChromeOSdir | Where-Object Name -Match "chromeos_\d+.\d+.\d+_reven_recovery_stable-channel_mp-v\d+.img").Name

        if (!($oldIMG -match $latestChromeOSIMG)) {
            $ISOs += , @( $latestChromeOS, "dir=$ChromeOSdir" )
        }
    }

    if ($GetWin10) {
        $win10dir = "Installation-Discs/Windows"
        $latestWin10 = (Invoke-Expression "$powershell $fido_dir/Fido.ps1 -Win 10 -Ed Pro -Arch x64 -Lang English -Rel latest -GetUrl") -replace " ", ""
        $ISOs += , @( $latestWin10, "dir=$win10dir" )
    }

    if ($GetWin11) {
        $win11dir = "Installation-Discs/Windows"
        $latestWin11 = (Invoke-Expression "$powershell $fido_dir/Fido.ps1 -Win 11 -Ed Pro -Arch x64 -Lang English -Rel latest -GetUrl") -replace " ", ""
        $ISOs += , @( $latestWin11, "dir=$win11dir" )
    }


    $ubuntudir = "Installation-Discs/Linux/Ubuntu"
    $versions = ($ubuntu.Links | Select-Object -Skip 4 | Where-Object href -Match "\d\d\.04(\.\d)?/").href
    $latest2 = ($versions | Select-Object -last 2) -replace '/', ''
    if ($latest2[0] -match "$($latest2[1])\.\d") {
        $latest = $latest2[0]
    } else {
        $latest = $latest2[1]
    }
    $latestubuntu = "http://releases.ubuntu.com/$latest/ubuntu-$latest-desktop-amd64.iso.torrent"
    $latestubuntuISO = ($latestubuntu -split '/' | Select-Object -last 1) -replace '.torrent$', ''
    $oldISO = (Get-ChildItem $ubuntudir | Where-Object Name -Match "ubuntu-\d\d\.04(\.\d)?-desktop-amd64.iso").Name

    if (!($oldISO -match $latestubuntuISO)) {
        $ISOs += , @( $latestubuntu, "dir=$ubuntudir" )
    }

    $kubuntudir = "Installation-Discs/Linux/Ubuntu"
    $versions = ($kubuntu.Links | Select-Object -Skip 4 | Where-Object href -Match "\d\d\.04(\.\d)?/").href
    $latest2 = ($versions | Select-Object -last 2) -replace '/', ''
    if ($latest2[0] -match "$($latest2[1])\.\d") {
        $latest = $latest2[0]
    } else {
        $latest = $latest2[1]
    }
    $latestkubuntu = "https://cdimage.ubuntu.com/kubuntu/releases/$latest/release/kubuntu-$latest-desktop-amd64.iso.torrent"
    $latestkubuntuISO = ($latestkubuntu -split '/' | Select-Object -last 1) -replace '.torrent$', ''
    $oldISO = (Get-ChildItem $kubuntudir | Where-Object Name -Match "kubuntu-\d\d\.04(\.\d)?-desktop-amd64.iso").Name

    if (!($oldISO -match $latestkubuntuISO)) {
        $ISOs += , @( $latestkubuntu, "dir=$kubuntudir" )
    }

    $matedir = "Installation-Discs/Linux/Ubuntu"
    $versions = ($mate.Links | Select-Object -Skip 4 | Where-Object href -Match "\d\d\.04(\.\d)?/").href
    $latest2 = ($versions | Select-Object -last 2) -replace '/', ''
    if ($latest2[0] -match "$($latest2[1])\.\d") {
        $latest = $latest2[0]
    } else {
        $latest = $latest2[1]
    }
    $latestmate = "http://cdimage.ubuntu.com/ubuntu-mate/releases/$latest/release/ubuntu-mate-$latest-desktop-amd64.iso.torrent"
    $latestmateISO = ($latestmate -split '/' | Select-Object -last 1) -replace '.torrent$', ''
    $oldISO = (Get-ChildItem $matedir | Where-Object Name -Match "ubuntu-mate-\d\d\.04(\.\d)?-desktop-amd64.iso").Name

    if (!($oldISO -match $latestmateISO)) {
        $ISOs += , @( $latestmate, "dir=$matedir" )
    }


    $MXLinuxdir = "Installation-Discs/Linux"
    $versions = ($MXLinux.Links | Where-Object href -Match "https://sourceforge.net/projects/mx-linux/files/Final/Xfce/MX-.*_ahs_x64.iso/download").href
    $latestMXLinux = ($versions | Select-Object -last 1)
    $latestMXLinuxISO = ($latestMXLinux -split '/' | Select-Object -skiplast 1 | Select-Object -last 1)
    $oldISO = (Get-ChildItem $MXLinuxdir | Where-Object Name -Match "MX-.*\d_ahs_x64.iso").Name

    if (!($oldISO -match $latestMXLinuxISO)) {
        $ISOs += , @( $latestMXLinux, "dir=$MXLinuxdir" )
    }

    $tailsdir = "Other"
    $latest = ($tails.Links | Select-Object -Skip 7 | Where-Object href -Match "tails-amd64-\d\.\d+(.\d)?.iso.torrent").href
    $latesttails = "https://tails.boum.org/torrents/files/$latest"
    $latesttailsISO = ($latesttails -split '/' | Select-Object -last 1) -replace '.torrent$', ''
    $oldISO = (Get-ChildItem $tailsdir | Where-Object Name -Match "tails-amd64-\d\.\d+(.\d)?.iso$").Name

    if (!($oldISO -match $latesttailsISO)) {
        $ISOs += , @( $latesttails, "dir=$tailsdir", "select-file=1" )
    }

    $zorindir = "Installation-Discs/Linux/Zorin-OS"
    $versions = ($zorin.links | select-object -last 1).href.Trim('/')
    $latest = ((Invoke-WebRequest "https://distro.ibiblio.org/zorinos/$versions").links | Where-Object href -match "Zorin-OS-\d\d(\.\d)?-Core-64-bit\.iso$").href | Select-Object -Last 1
    $latestzorin = "https://distro.ibiblio.org/zorinos/$versions/$latest"
    $latestzorinISO = $latestzorin -split '/' | Select-Object -last 1
    $oldISO = (Get-ChildItem $zorindir | Where-Object Name -Match "Zorin-OS-\d\d(\.\d)?-Core-64-bit.iso$").Name

    if (!($oldISO -match $latestzorinISO)) {
        $ISOs += , @( $latestzorin, "dir=$zorindir" )
    }

    $latest = ((Invoke-WebRequest "https://distro.ibiblio.org/zorinos/$versions").links | Where-Object href -match "Zorin-OS-\d\d(\.\d)?-Lite-64-bit\.iso$").href | Select-Object -Last 1
    $latestzorin = "https://distro.ibiblio.org/zorinos/$versions/$latest"
    $latestzorinISO = $latestzorin -split '/' | Select-Object -last 1
    $oldISO = (Get-ChildItem $zorindir | Where-Object Name -Match "Zorin-OS-\d\d(\.\d)?-Lite-64-bit.iso$").Name

    if (!($oldISO -match $latestzorinISO)) {
        $ISOs += , @( $latestzorin, "dir=$zorindir" )
    }

    $Archdir = "Installation-Discs/Linux/Archlinux"
    $latestArch = ($Arch.Links | Where-Object HREF -Match "^magnet").href -Replace "&amp;", "&"
    $latestArchISO = ($latestArch -split "&" | Where-Object { $_ -Match "^dn=" }) -Split "=" | Select-Object -Last 1
    $oldISO = (Get-ChildItem $Archdir | Where-Object Name -Match "archlinux-\d\d\d\d\.\d\d\.\d\d-x86_64.iso$").Name

    if (!($oldISO -match $latestArchISO)) {
        $ISOs += , @( $latestArch, "dir=$Archdir" )
    }


    $Artixdir = "Installation-Discs/Linux/Archlinux"
    $latestArtix = ($Artix.Links | Where-Object HREF -Match "base-openrc-\d\d\d\d\d\d\d\d-x86_64.iso$").HREF
    $latestArtixISO = ($latestArtix -split '/' | Select-Object -last 1)
    $oldISO = (Get-ChildItem $Artixdir | Where-Object Name -Match "base-openrc-\d\d\d\d\d\d\d\d-x86_64.iso$").Name

    if (!($oldISO -match $latestArtixISO)) {
        $ISOs += , @( $latestArtix, "dir=$Artixdir" )
    }

    # https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20210127T214504Z/install-amd64-minimal-20210127T214504Z.iso
    $Gentoodir = "Installation-Discs/Linux/Gentoo"
    $latestGentoo = ($Gentoo.links | Where-Object href -like "*install-amd64-minimal-*.iso").href | Select-Object -first 1
    $latestGentooISO = ($latestGentoo -split '/' | Select-Object -last 1)
    $latestdate = $latestGentoo -split '/' | Select-Object -last 2 | Select-Object -First 1
    $lateststage3 = "https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/$latestdate/stage3-amd64-systemd-$latestdate.tar.xz"
    $oldISO = (Get-ChildItem $Gentoodir | Where-Object Name -Match "install-amd64-minimal-\d\d\d\d\d\d\d\dT\d\d\d\d\d\dZ.iso$").Name

    if (!($oldISO -match $latestGentooISO)) {
        Remove-Item -Recurse $Gentoodir
        $ISOs += , @( $latestGentoo, "dir=$Gentoodir" )
        $ISOs += , @( $lateststage3, "dir=$Gentoodir" )
    }

    $FreeBSDdir = "Installation-Discs"
    $latestFreeBSD = ($FreeBSD.Links | Where-Object title -like "*-RELEASE" | Select-Object -last 1).title -replace "-RELEASE", ""
    $latestFreeBSDISO = "https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/$latestFreeBSD/FreeBSD-$latestFreeBSD-RELEASE-amd64-dvd1.iso"
    $oldISO = (Get-ChildItem $FreeBSDdir | Where-Object Name -Match "FreeBSD-\d\d\.\d-RELEASE-amd64-dvd1.iso$").Name

    if (!($oldISO -match "FreeBSD-$latestFreeBSD-RELEASE-amd64-dvd1.iso")) {
        $ISOs += , @( $latestFreeBSDISO, "dir=$FreeBSDdir" )
    }

    $Manjarodir = "Installation-Discs/Linux/Archlinux"
    $latestManjaro = ($Manjaro.Links | Where-Object href -like "*manjaro-kde-*.iso*" | Select-Object -first 1).href
    $latestManjaroISO = ($latestManjaro -split '/' | Select-Object -last 1) -replace ".torrent", ""
    $oldISO = (Get-ChildItem $Manjarodir | Where-Object Name -Match "manjaro-kde*").Name

    if (!($oldISO -match $latestManjaroISO)) {
        $ISOs += , @( $latestManjaro, "dir=$Manjarodir" )
    }

    $Endeavordir = "Installation-Discs/Linux/Archlinux"
    $latestEndeavor = ($Endeavor.Links | Where-Object href -like "*https://mirrors.gigenet.com/endeavouros/iso/EndeavourOS_Endeavour*" | Select-Object -first 1).href
    $latestEndeavorISO = ($latestEndeavor -split '/' | Select-Object -last 1)
    $oldISO = (Get-ChildItem $Endeavordir | Where-Object Name -Match "endeavouros-*").Name

    if (!($oldISO -match $latestEndeavorISO)) {
        $ISOs += , @( $latestEndeavor, "dir=$Endeavordir" )
    }
    
    $Silverbluedir = "Installation-Discs/Linux/Fedora"
    $latestSilverblue = ($Silverblue.links | Where-Object href -match 'Fedora-silverblue-ostree-x86_64.*\d.torrent' | Select-Object -Last 1).HREF
    $latestSilverblueISO = $latestSilverblue -split '/' | Select-Object -Last 1
    $oldISO = (Get-ChildItem $Silverbluedir | Where-Object Name -Match "Fedora-silverblue-ostree-x86_64.*.iso").Name

    if (!(($oldISO -split '-' | Select-Object -Index 4) -match ($latestSilverblueISO -split '-' -replace '.torrent',''| Select-Object -Index 4))) {
        $ISOs += , @( $latestSilverblue, "dir=$Silverbluedir", "select-file=2" )
    }

    $Kinoitedir = "Installation-Discs/Linux/Fedora"
    $latestKinoite = ($Kinoite.links | Where-Object href -match 'Fedora-Kinoite-ostree-x86_64.*\d.torrent' | Select-Object -Last 1).HREF
    $latestKinoiteISO = $latestKinoite -split '/' | Select-Object -Last 1
    $oldISO = (Get-ChildItem $Kinoitedir | Where-Object Name -Match "Fedora-Kinoite-ostree-x86_64.*.iso").Name

    if (!(($oldISO -split '-' | Select-Object -Index 4) -match ($latestKinoiteISO -split '-' -replace '.torrent',''| Select-Object -Index 4))) {
        $ISOs += , @( $latestKinoite, "dir=$Kinoitedir", "select-file=2" )
    }
    $voiddir = "Installation-Discs/Linux"
    $latestvoidISO = ($void.Links | Where-Object href -match "void-live-x86_64-\d\d\d\d\d\d\d\d-xfce.iso").href
    $latestvoid = "https://repo-default.voidlinux.org/live/current/$latestvoidISO"
    $oldISO = (Get-ChildItem $voiddir | Where-Object Name -Match "void-live-x86_64-\d\d\d\d\d\d\d\d-xfce.iso").Name

    if (!($oldISO -match $latestvoidISO)) {
        $ISOs += , @( $latestvoid, "dir=$voiddir", "out=$latestvoidISO" )
    }
    
    $ISOs | ForEach-Object { $_ -join "`n`t" } |  Out-File -Encoding "UTF8" "./links.txt"
    if ($psversiontable.PSVersion.Major -le 5 ) {
        $content = Get-Content "./links.txt"
        [IO.File]::WriteAllLines(("./links.txt" | Resolve-Path), $content)
    }
} finally {
    if (!($SkipDownload)) {
        Clear-Host
        if ($isLinux) {
            & aria2c --seed-time=0 -i "./links.txt" -c -j2 --rpc-save-upload-metadata false --bt-remove-unselected-file true
        } else {
            & $aria2_dir/aria2c.exe --seed-time=0 -i "./links.txt" -c -j2 --rpc-save-upload-metadata false --bt-remove-unselected-file true
            Remove-Item -Recurse -Force "$aria2_dir", "$temp/aria2.zip"
        }
        if ($GetWin10 -or $GetWin11) {
            Remove-Item -Recurse -Force "$fido_dir", "$temp/fido.zip"
        }
        Get-ChildItem . -recurse -include *.torrent | Remove-Item
        Remove-Item "./links.txt"
        
        Move-Item "$("Other/tails-*-iso" | Resolve-Path)/*.iso" "Other/"
        foreach ($folder in $((Get-ChildItem -Directory "Other").Name)) {
            Remove-Item -Recurse -Force "Other/$folder/"
        }

        $(Get-ChildItem "Installation-Discs/Linux/Fedora" -Directory | Where-Object Name -match 'Fedora-.*$') | ForEach-Object {
            Move-Item "$_/*.iso" "Installation-Discs/Linux/Fedora/"
            Remove-Item $_
        }

        foreach ($folder in $((Get-ChildItem -Directory "Installation-Discs/Linux").Name | Where-Object { $_ -notmatch "(Archlinux|Fedora|Ubuntu|Gentoo|Zorin-OS)$" })) {
            Remove-Item -Recurse -Force "Installation-Discs/Linux/$folder/"
        }

        if ($GetIMGs -or $GetRMDs) {
            $ChromeOSZIP = Get-ChildItem $ChromeOSdir | Where-Object Name -Match "chromeos_\d+.\d+.\d+_reven_recovery_stable-channel_mp-v\d+.bin.zip"
            $ChromeOSfile = $ChromeOSZIP.Name -replace ".zip", ""
            Expand-Archive -Path $ChromeOSZIP -DestinationPath $ChromeOSdir
            Remove-Item $ChromeOSZIP
        }
        if ($GetIMGs) {
            Move-Item "$ChromeOSdir/$ChromeOSfile" "$ChromeOSdir/$($ChromeOSfile -replace ".bin",".img")"
        } elseif ($GetRMDs) {
            Move-Item "$ChromeOSdir/$ChromeOSfile" "$ChromeOSdir/$($ChromeOSfile -replace ".bin",".RMD")"
        }
    }
}
