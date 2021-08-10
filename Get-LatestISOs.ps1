#!/bin/env pwsh
param (
    [switch]
    $SkipDownload,
    [switch]
    $GetIMGs
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

try {
    # Ubuntu ISOs
    $ubuntu = Invoke-WebRequest "http://cdimage.ubuntu.com/ubuntu/releases/"
    $kubuntu = Invoke-WebRequest "https://cdimage.ubuntu.com/kubuntu/releases/"
    $mate = Invoke-WebRequest "http://cdimage.ubuntu.com/ubuntu-mate/releases/"
    $PopOS = [xml](Invoke-WebRequest "https://pop-iso.sfo2.cdn.digitaloceanspaces.com/")

    # Arch ISOs
    $Arch = Invoke-WebRequest "https://www.archlinux.org/download/"
    $Artix = Invoke-WebRequest "https://iso.artixlinux.org/isos.php"

    # Other ISOs
    $MXLinux = Invoke-WebRequest "https://mirrors.evowise.com/mxlinux-iso/MX/Final/"
    $tails = Invoke-WebRequest "https://tails.boum.org/torrents/files/"

    # Fedora Silverblue
    $Silverblue = Invoke-WebRequest "https://torrent.fedoraproject.org/"

    # Manjaro
    $Manjaro = Invoke-WebRequest "https://manjaro.org/downloads/official/kde/"

    # EndeavorOS
    $Endeavor = Invoke-WebRequest "https://endeavouros.com/latest-release/"

    # Gentoo
    $Gentoo = Invoke-WebRequest "https://www.gentoo.org/downloads/"

    # FreeBSD
    $FreeBSD = Invoke-WebRequest "https://download.freebsd.org/ftp/releases/amd64/amd64/"

    # NixOS
    $NixOS = Invoke-WebRequest "https://nixos.org/download.html"

    if ($GetIMGs) {
        $cloudready = Invoke-WebRequest "https://www.neverware.com/freedownload"

        $cloudreadydir = "Installation-Discs"
        $latestcloudready = ($cloudready.links | ? href -like https://*.cloudfront.net/cloudready-free-*-64bit/cloudready-free-*.zip).href
        $latestcloudreadyIMG = $latestcloudready -replace ".zip",".RMD"
        $oldIMG = (Get-ChildItem $cloudreadydir | Where-Object Name -Match "cloudready-free-\d\d.\d.\d\d-64bit.RMD").Name

        if (!($oldIMG -match $latestcloudreadyIMG)) {
            $ISOs += , @( $latestcloudready, "dir=$cloudreadydir" )
        }
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
    $versions = ($MXLinux.Links | Select-Object -Skip 1 | Where-Object href -Match "\d_x64.iso$").href
    $latest = ($versions | Select-Object -last 1)
    $latestMXLinux = "https://mirrors.evowise.com/mxlinux-iso/MX/Final/$latest"
    $latestMXLinuxISO = ($latestMXLinux -split '/' | Select-Object -last 1)
    $oldISO = (Get-ChildItem $MXLinuxdir | Where-Object Name -Match "MX-.*\d_x64.iso").Name

    if (!($oldISO -match $latestMXLinuxISO)) {
        $ISOs += , @( $latestMXLinux, "dir=$MXLinuxdir" )
    }


    $PopOSdir = "Installation-Discs/Linux"
    $versions = $PopOS.ListBucketResult.Contents.Key | Where-Object { $_ -Match "intel_\d\.iso$" }
    $latest = ($versions | Select-Object -last 1)
    $latestPopOS = "https://pop-iso.sfo2.cdn.digitaloceanspaces.com/$latest"
    $latestPopOSISO = ($latestPopOS -split '/' | Select-Object -last 1)
    $oldISO = (Get-ChildItem $PopOSdir | Where-Object Name -Match "pop-os_\d\d\.\d\d(\.\d)?_amd64_intel_\d(\d)?").Name

    if (!($oldISO -match $latestPopOSISO)) {
        $ISOs += , @( $latestPopOS, "dir=$PopOSdir" )
    }


    $tailsdir = "Other"
    $latest = ($tails.Links | Select-Object -Skip 7 | Where-Object href -Match "tails-amd64-\d\.\d.iso.torrent").href
    $latesttails = "https://tails.boum.org/torrents/files/$latest"
    $latesttailsISO = ($latesttails -split '/' | Select-Object -last 1) -replace '.torrent$', ''
    $oldISO = (Get-ChildItem $tailsdir | Where-Object Name -Match "tails-amd64-\d\.\d.iso$").Name

    if (!($oldISO -match $latesttailsISO)) {
        $ISOs += , @( $latesttails, "dir=$tailsdir", "select-file=1" )
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
    $latestGentoo = ($Gentoo.links | ? href -like "*install-amd64-minimal-*.iso").href|select -first 1
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
    $latestFreeBSD = ($FreeBSD.Links | ? title -like "*-RELEASE"|select -last 1).title -replace "-RELEASE", ""
    $latestFreeBSDISO = "https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/$latestFreeBSD/FreeBSD-$latestFreeBSD-RELEASE-amd64-dvd1.iso"
    $oldISO = (Get-ChildItem $FreeBSDdir | Where-Object Name -Match "FreeBSD-\d\d\.\d-RELEASE-amd64-dvd1.iso$").Name

    if (!($oldISO -match "FreeBSD-$latestFreeBSD-RELEASE-amd64-dvd1.iso")) {
        $ISOs += , @( $latestFreeBSDISO, "dir=$FreeBSDdir" )
    }

    $Manjarodir = "Installation-Discs/Linux/Archlinux"
    $latestManjaro = ($Manjaro.Links | ? href -like "*manjaro-kde-*.iso*"| select -first 1).href
    $latestManjaroISO = ($latestManjaro -split '/' | Select-Object -last 1)
    $oldISO = (Get-ChildItem $Manjarodir | Where-Object Name -Match "manjaro-kde*").Name

    if (!($oldISO -match $latestManjaroISO)) {
        $ISOs += , @( $latestManjaro, "dir=$Manjarodir" )
    }

    $Endeavordir = "Installation-Discs/Linux/Archlinux"
    $latestEndeavor = ($Endeavor.Links | ? href -like "*https://github.com/endeavouros-team/ISO/releases/download/1-EndeavourOS-ISO-releases-archive*"| select -first 1).href
    $latestEndeavorISO = ($latestEndeavor -split '/' | Select-Object -last 1)
    $oldISO = (Get-ChildItem $Endeavordir | Where-Object Name -Match "endeavouros-*").Name

    if (!($oldISO -match $latestEndeavorISO)) {
        $ISOs += , @( $latestEndeavor, "dir=$Endeavordir" )
    }
    
    $Silverbluedir = "Installation-Discs/Linux"
    $latestSilverblue = ($Silverblue.links | Where-Object href -match 'Fedora-silverblue-ostree-x86_64.*.torrent' | Select-Object -First 1).HREF
    $latestSilverblueISO = ($(Invoke-WebRequest "https://silverblue.fedoraproject.org/download").Links.HREF | Select-Object -first 7 | Select-Object -last 1) -split '/' | Select-Object -last 1
    $oldISO = (Get-ChildItem $Silverbluedir | Where-Object Name -Match "Fedora-silverblue-ostree-x86_64.*.iso").Name

    if (!($oldISO -match $latestSilverblueISO)) {
        $ISOs += , @( $latestSilverblue, "dir=$Silverbluedir", "select-file=2" )
    }

    $NixOSdir = "Installation-Discs/Linux"
    $latest = ($NixOS.Links | Where-Object href -like "*channels.nixos.org*plasma*.iso").href
    $latestNixOS = ($latest -split '/' | Select-Object -Last 2 | Select-Object -First 1)
    $latestNixOSISO = "$latestNixOS-x86_64.iso"
    $oldISO = (Get-ChildItem $NixOSdir | Where-Object Name -Match "nixos-\d\d\.\d\d-x86_64.iso").Name

    if (!($oldISO -match $latestNixOSISO)) {
        $ISOs += , @( $latest, "dir=$NixOSdir", "out=$latestNixOSISO" )
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
        Get-ChildItem . -recurse -include *.torrent | Remove-Item
        Remove-Item "./links.txt"
        
        Move-Item "$("Other/tails-*-iso" | Resolve-Path)/*.iso" "Other/"
        foreach ($folder in $((Get-ChildItem -Directory "Other").Name)) {
            Remove-Item -Recurse -Force "Other/$folder/"
        }

        Move-Item "$(Get-ChildItem "Installation-Discs/Linux" -Directory | Where-Object Name -match 'Fedora-Silverblue.*$')/*.iso" "Installation-Discs/Linux/"
        foreach ($folder in $((Get-ChildItem -Directory "Installation-Discs/Linux").Name | Where-Object { $_ -notmatch "Archlinux|Ubuntu|Gentoo" })) {
            Remove-Item -Recurse -Force "Installation-Discs/Linux/$folder/"
        }

        if ($GetIMGs) {
            $cloudreadyZIP = Get-ChildItem $cloudreadydir | Where-Object Name -Match "cloudready-free-\d\d.\d.\d\d-64bit.zip"
            Expand-Archive -Path $cloudreadyZIP -DestinationPath $cloudreadydir
            Remove-Item $cloudreadyZIP
            Move-Item "$cloudreadydir/$($cloudreadyZIP.Name -replace ".zip",".bin")" "$cloudreadydir/$($cloudreadyZIP.Name -replace ".zip",".RMD")"
        }
    }
}
