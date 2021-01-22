
<#
Created by: Carlos Martinez - @cmartinezone
Generate Ionic Vue JS Project
Version 1.0
#>

Write-Host "? " -NoNewline -ForegroundColor Green
$projectName = Read-Host "Project name"
$typeScriptRemoved = $false

if ( ($null -ne $projectName) -or ( 1 -ne $projectName.Count) ) {

  <# Remove spaces if they exist on the project name #>
  $projectName = $projectName -replace " ", "-"

  <# Create standard ionic vue Ts project #>
  ionic start $projectName --type="vue"

  Write-Host "`nPackage Manager ?" -ForegroundColor Yellow
  $packageManager = Read-Host "NPM: 1 YARN: 2 "

  Set-Location -Path "./$projectName"

  if (($packageManager -eq 2) -or ($packageManager -match "yarn")) {
    yarn install
    Write-Host "Removing TypeScript dependencies..."
    yarn remove typescript @types/jest @typescript-eslint/eslint-plugin @typescript-eslint/parser @vue/cli-plugin-typescript
    $typeScriptRemoved = $true
  }
  else {
    npm install
    Write-Host "Removing TypeScript dependencies..."
    npm uninstall --save typescript @types/jest @typescript-eslint/eslint-plugin @typescript-eslint/parser @vue/cli-plugin-typescript
    $typeScriptRemoved = $true
  }

  if ($typeScriptRemoved) {
    <# Remove TypeScript from .eslintrc.js #>
    Write-Host "Removing TypeScript from .eslintrc.js" -ForegroundColor Yellow

    $eslintFile = "./.eslintrc.js"
    (Get-Content $eslintFile ) -replace "'@vue/typescript/recommended'", '' | Set-Content $eslintFile
    (Get-Content $eslintFile ) -replace "'@vue/typescript/recommended'", '' | Set-Content $eslintFile
    (Get-Content $eslintFile ) -replace " '@typescript-eslint/no-explicit-any': 'off',", '' | Set-Content $eslintFile
    (Get-Content $eslintFile ) -replace " '@typescript-eslint/no-explicit-any': 'off'", '' | Set-Content $eslintFile
    Write-Host "Done!" -ForegroundColor Green

    Write-Host "Renaming files from .ts to .js " -ForegroundColor Yellow
    Rename-Item -Path "./src/main.ts" -NewName "main.js"
    Rename-Item -Path "./src/router/index.ts" -NewName "index.js"
    Write-Host "Done!" -ForegroundColor Green

    Write-Host "Updating files" -ForegroundColor Yellow
    $routerFile = "./src/router/index.js"
    (Get-Content $routerFile ) -replace "import { RouteRecordRaw } from 'vue-router';", '' | Set-Content $routerFile
    (Get-Content $routerFile ) -replace "import { RouteRecordRaw } from 'vue-router'", '' | Set-Content $routerFile
    (Get-Content $routerFile ) -replace 'Array<RouteRecordRaw>', '' | Set-Content $routerFile
    (Get-Content $routerFile ) -replace 'routes:', 'routes' | Set-Content $routerFile
    Remove-Item  "./src/shims-vue.d.ts" -Force

    $componentsPath = "./src/components"
    if ( Test-Path -Path $componentsPath ) {
      $components = Get-ChildItem -Path $componentsPath

      $components | % {
        (Get-Content (  $componentsPath + "/" + $_.Name) ) -replace 'lang="ts"', '' | Set-Content ( $componentsPath + "/" + $_.Name);
        (Get-Content (  $componentsPath + "/" + $_.Name) ) -replace 'as any', '' | Set-Content ( $componentsPath + "/" + $_.Name);

      }
    }

    $viewsPath = "./src/views"
    if (Test-Path -Path   $viewsPath) {

      Get-ChildItem -Path "./src/views" | % {
        ( Get-Content (  $viewsPath + "/" + $_.Name) ) -replace 'lang="ts"', '' | Set-Content (  $viewsPath + "/" + $_.Name)
        ( Get-Content (  $viewsPath + "/" + $_.Name) ) -replace 'as any', '' | Set-Content (  $viewsPath + "/" + $_.Name)
        ( Get-Content (  $viewsPath + "/" + $_.Name) ) -replace 'ev: CustomEvent', 'ev' | Set-Content (  $viewsPath + "/" + $_.Name)
        ( Get-Content (  $viewsPath + "/" + $_.Name) ) -replace 'as string', '' | Set-Content (  $viewsPath + "/" + $_.Name)
      }
    }

    if (Test-Path -Path "./src/data") {
      Rename-Item -Path "./src/data/messages.ts" -NewName "messages.js"
      $data = Get-Content "./src/data/messages.js"
      $data[0] = $null
      $data[1] = $null
      $data[2] = $null
      $data[3] = $null
      $data[4] = $null
      $data[5] = $null
      $data[6] = $null
      $data[7] = "const messages = ["

      $data = $data -replace "id: number", "id"
      $data | Set-Content "./src/data/messages.js"
    }

    (Get-Content "./src/app.vue" ) -replace 'url: string', 'url' | Set-Content "./src/app.vue"
    (Get-Content "./src/app.vue" ) -replace 'lang="ts"', '' | Set-Content "./src/app.vue"

    Write-Host "Done!" -ForegroundColor Green
    Write-Host "Enjoy :)" -ForegroundColor Green
    Start-Sleep 2
    ionic serve
  }
}
else {
  Write-Error -Message  "You did not type the project name!"
}









