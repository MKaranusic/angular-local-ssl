function Check-IsElevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return 1;
    }
    else {
        return 0;
    }
}

if (Check-IsElevated -eq 1) {
    #install localhost ssl cert
    certutil -addstore Root .\server\sslcert\localhost.crt

    $angularRootDir = Read-Host -Prompt 'Path to root dir of angular project'
    $serverDir = "$((Get-Item .).FullName)\server\"

    Copy-Item -Path $serverDir -Destination $angularRootDir -Recurse
    
    $angularJsonFile = Get-ChildItem -Recurse -Filter "angular.json" -File -ErrorAction SilentlyContinue -Path $angularRootDir
    $defaultProject = ((Get-Content -Path $angularJsonFile.FullName) | ConvertFrom-Json).defaultProject
    (Get-Content -Path "$($angularRootDir)server\node-server.js") |
    ForEach-Object { $_ -Replace 'DEFAULTDIRECTORY', $defaultProject } |
    Set-Content -Path "$($angularRootDir)server\node-server.js"

    $packageJsonFile = Get-ChildItem -Filter "package.json" -File -ErrorAction SilentlyContinue -Path $angularRootDir
    $json = (Get-Content -Path $packageJsonFile.FullName) | ConvertFrom-Json    
    $json.scripts | Add-Member -Type NoteProperty -Name 'node-server' -Value "ng build --prod && node server/node-server.js" -Force
    $json | ConvertTo-Json -Compress | ForEach-Object {
        [Regex]::Replace($_, 
            "\\u(?<Value>[a-zA-Z0-9]{4})", {
                param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                            [System.Globalization.NumberStyles]::HexNumber))).ToString() } ) } | Set-Content $packageJsonFile.FullName
}
else {
    Read-Host -Prompt "Script must be run with Admin rights"
}