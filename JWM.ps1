# Add necessary assembly for clipboard access
Add-Type -AssemblyName System.Windows.Forms

# Function to get clipboard text
function Get-ClipboardText {
    return [System.Windows.Forms.Clipboard]::GetText()
}

# Function to convert tab-delimited text to markdown table
function ConvertTo-MarkdownTable {
    param([string]$inputText)
    $lines = $inputText -split "\r?\n"
    $headers = $lines[0] -split "\t"
    $separator = @($headers | ForEach-Object { '---' }) -join "|"
    $headerRow = $headers -join "|"

    # Output the markdown header
    Write-Host "|$headerRow|"
    Write-Host "|$separator|"

    # Output each row of data
    foreach ($line in $lines[1..($lines.Count - 1)]) {
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $row = ($line -split "\t") -join "|"
            Write-Host "|$row|"
        }
    }
}

# Function to monitor clipboard for changes and process tab-delimited data
function Monitor-Clipboard {
    $lastClip = Get-ClipboardText
    Write-Host "Monitoring clipboard for tab-delimited text. Press Ctrl+C to exit."
    try {
        while ($true) {
            Start-Sleep -Seconds 1  # Polling interval
            $currentClip = Get-ClipboardText
            if ($currentClip -ne $lastClip -and $currentClip -match "\t") {
                Write-Host "Clipboard changed, detected tab-delimited text:"
                ConvertTo-MarkdownTable -inputText $currentClip
                $lastClip = $currentClip
            }
        }
    } catch {
        Write-Host "Exiting clipboard monitor..."
    }
}

# Call the monitor function
Monitor-Clipboard
