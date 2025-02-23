Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Drawing.Design

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class IconExtractor {
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SHGetFileInfo(string pszPath, uint dwFileAttributes, 
        ref SHFILEINFO psfi, uint cbSizeFileInfo, uint uFlags);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct SHFILEINFO {
        public IntPtr hIcon;
        public int iIcon;
        public uint dwAttributes;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
        public string szDisplayName;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 80)]
        public string szTypeName;
    }

    public const uint SHGFI_ICON = 0x100;
    public const uint SHGFI_LARGEICON = 0x0;
    public const uint SHGFI_SMALLICON = 0x1;
}
"@

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Advanced Bulk File Renamer'
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = 'CenterScreen'

$folderLabel = New-Object System.Windows.Forms.Label
$folderLabel.Location = New-Object System.Drawing.Point(10,20)
$folderLabel.Size = New-Object System.Drawing.Size(100,20)
$folderLabel.Text = 'Select Folder:'

$folderButton = New-Object System.Windows.Forms.Button
$folderButton.Location = New-Object System.Drawing.Point(10,50)
$folderButton.Size = New-Object System.Drawing.Size(100,23)
$folderButton.Text = 'Browse'

$selectedFolderTextBox = New-Object System.Windows.Forms.TextBox
$selectedFolderTextBox.Location = New-Object System.Drawing.Point(120,50)
$selectedFolderTextBox.Size = New-Object System.Drawing.Size(650,20)
$selectedFolderTextBox.Enabled = $false

$imageList = New-Object System.Windows.Forms.ImageList
$imageList.ImageSize = New-Object System.Drawing.Size(16,16)

$fileListView = New-Object System.Windows.Forms.ListView
$fileListView.Location = New-Object System.Drawing.Point(10,100)
$fileListView.Size = New-Object System.Drawing.Size(760,350)
$fileListView.View = 'Details'
$fileListView.CheckBoxes = $true
$fileListView.SmallImageList = $imageList

$fileListView.Columns.Add('Icon', 25)
$fileListView.Columns.Add('File Name', 200)
$fileListView.Columns.Add('Full Path', 500)

function Get-FileIcon {
    param([string]$FilePath)
    
    $shinfo = New-Object IconExtractor+SHFILEINFO
    $shinfo.szDisplayName = New-Object char[] 260
    $shinfo.szTypeName = New-Object char[] 80
    
    $flags = [IconExtractor]::SHGFI_ICON + [IconExtractor]::SHGFI_SMALLICON
    $result = [IconExtractor]::SHGetFileInfo($FilePath, 0, [ref]$shinfo, 
        [System.Runtime.InteropServices.Marshal]::SizeOf($shinfo), $flags)
    
    if ($result -ne 0) {
        $icon = [System.Drawing.Icon]::FromHandle($shinfo.hIcon)
        return $icon
    }
    return $null
}

$newNameLabel = New-Object System.Windows.Forms.Label
$newNameLabel.Location = New-Object System.Drawing.Point(10,460)
$newNameLabel.Size = New-Object System.Drawing.Size(200,20)
$newNameLabel.Text = 'New Base File Name:'

$newNameTextBox = New-Object System.Windows.Forms.TextBox
$newNameTextBox.Location = New-Object System.Drawing.Point(10,485)
$newNameTextBox.Size = New-Object System.Drawing.Size(300,20)

$renameButton = New-Object System.Windows.Forms.Button
$renameButton.Location = New-Object System.Drawing.Point(320,485)
$renameButton.Size = New-Object System.Drawing.Size(100,23)
$renameButton.Text = 'Rename Files'

$resultLabel = New-Object System.Windows.Forms.Label
$resultLabel.Location = New-Object System.Drawing.Point(10,520)
$resultLabel.Size = New-Object System.Drawing.Size(760,50)

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

$folderButton.Add_Click({
    $result = $folderBrowser.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $fileListView.Items.Clear()
        $imageList.Images.Clear()
        
        $files = Get-ChildItem -Path $folderBrowser.SelectedPath -File -Recurse

        foreach ($file in $files) {
            $icon = Get-FileIcon -FilePath $file.FullName
            
            if ($icon) {
                $imageList.Images.Add($icon)
                $iconIndex = $imageList.Images.Count - 1
                
                $item = New-Object System.Windows.Forms.ListViewItem("",$iconIndex)
                $item.SubItems.Add($file.Name)
                $item.SubItems.Add($file.FullName)
                
                $fileListView.Items.Add($item)

                $icon.Dispose()
            }
        }

        $selectedFolderTextBox.Text = $folderBrowser.SelectedPath
    }
})

$renameButton.Add_Click({
    $newBaseName = $newNameTextBox.Text
    
    if ([string]::IsNullOrWhiteSpace($newBaseName)) {
        [System.Windows.Forms.MessageBox]::Show('Please enter a new base name for the files.', 'Error', 'OK', 'Error')
        return
    }

    $selectedFiles = $fileListView.CheckedItems

    if ($selectedFiles.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('Please select at least one file to rename.', 'Error', 'OK', 'Error')
        return
    }

    try {
        $counter = 0
        foreach ($item in $selectedFiles) {
            $originalFile = [System.IO.FileInfo]::new($item.SubItems[2].Text)
            
            $newFileName = if ($counter -eq 0) { 
                "$newBaseName$($originalFile.Extension)" 
            } else { 
                "$newBaseName$counter$($originalFile.Extension)" 
            }
            
            $newFilePath = Join-Path $originalFile.DirectoryName $newFileName
            
            Rename-Item -Path $originalFile.FullName -NewName $newFileName

            $counter++
        }

        $resultLabel.Text = "Renamed $($selectedFiles.Count) files.`nBase Name: $newBaseName`nFolder: $($selectedFolderTextBox.Text)"
        
        $folderButton.PerformClick()
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", 'Error', 'OK', 'Error')
    }
})

$form.Controls.Add($folderLabel)
$form.Controls.Add($folderButton)
$form.Controls.Add($selectedFolderTextBox)
$form.Controls.Add($fileListView)
$form.Controls.Add($newNameLabel)
$form.Controls.Add($newNameTextBox)
$form.Controls.Add($renameButton)
$form.Controls.Add($resultLabel)

$form.Add_Shown({$form.Activate()})
$form.ShowDialog()