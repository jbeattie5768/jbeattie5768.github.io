#Powershell Script:  .\download_yt_audio.ps1
# Defaults
$DefaultRootFolder  = "C:\temp\yt-dlp"
$DefaultAudioFormat = "mp3"  # aac, alac, flac, m4a, mp3, opus, vorbis, wav
$DefaultFFmpegPath  = "C:\temp\yt-dlp\ffmpeg-master-latest-win64-gpl\bin"
$DefaultAutoPlay    = $false
$Verbosity          = "--quiet"  # Change to "--verbose" for more output

# Check UVX is available on the path
if (-not (Test-Path (get-command uvx.exe).Path)) {
    Write-Host "No uvx.exe found. Check it is available on your path."
    exit 1
}

# Get user inputs or use defaults
$UrlLink = Read-Host "URL/Link of Video"
if (-not $UrlLink) { Write-Error "You must provide a URL."; exit 1 }

[ValidateSet('aac', 'alac', 'flac', 'm4a', 'mp3', 'opus', 'vorbis', 'wav', '')]$AudioFormat = Read-Host 'Audio Format (default:' $DefaultAudioFormat')'
# It's a coarse error if it fails, but its at least a check
if (-not $AudioFormat) { $AudioFormat = $DefaultAudioFormat }  # '' option

$Filename = Read-Host "Output Filename (no extension)"
if (-not $Filename) { Write-Error "You must provide an output filename."; exit 1 }

$FFmpegPath = Read-Host 'FFMPEG Folder (default:' $DefaultFFmpegPath ')'
if (-not $FFmpegPath) { $FFmpegPath = $DefaultFFmpegPath }

# Validate ffmpeg path
$FFmpegExePath = Join-Path -Path $FFmpegPath -ChildPath "ffmpeg.exe"
if (-not (Test-Path -Path $FFmpegExePath)) {
    Write-Warning "FFmpeg executable not found at: $FFmpegExePath"
    exit 1
    # Alternatively ask user to get the path correct
}

$RootFolder = Read-Host 'Root Folder (default:' $DefaultRootFolder ')'
if (-not $RootFolder) { $RootFolder = $DefaultRootFolder }

# Ensure root folder exists
if (-not (Test-Path -Path $RootFolder)) {
    Write-Host "Creating $RootFolder"
    New-Item -Path $RootFolder -ItemType Directory -Force | Out-Null
}

$AutoPlay = Read-Host 'AutoPlay Audio after Extraction? (default off)'
if (-not($AutoPlay)) { $AutoPlay = $DefaultAutoPlay}

$OutFilename = "$Filename.$AudioFormat"  # Append format as extension

Set-Location -Path $RootFolder  # Go to root folder

# UVX args: use --no-cache to fetch latest yt-dlp version each time
$uvxArgs = @("--no-cache",
             "yt-dlp",
             "-x",
             "--audio-format", $AudioFormat,
             "--ffmpeg-location", $FFmpegPath,
             "-o", $OutFilename,
             $UrlLink,
             $Verbosity
             )

Write-Host "Running: uvx $($uvxArgs -join ' ')"
& uvx @uvxArgs
# Let UV handle errors

# Optionally play the downloaded audio
if ($AutoPlay) {
    $OutfilePath = Join-Path -Path $RootFolder -ChildPath $OutFilename
    if (Test-Path $OutfilePath) {
        Start-Process -FilePath $OutfilePath
    } else {
        Write-Warning "Downloaded file not found: $OutfilePath"
    }
}
# End of Script
