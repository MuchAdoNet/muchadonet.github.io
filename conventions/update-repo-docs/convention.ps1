Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$targetRepoRoot = (Get-Location).Path
$sourceRepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..' '..')).Path
$docsDirectory = Join-Path $sourceRepoRoot 'docs'
$mainDocPath = Join-Path $docsDirectory 'README.md'
$readmePath = Join-Path $targetRepoRoot 'README.md'
$skillsDirectory = Join-Path $targetRepoRoot 'skills'
$skillDirectory = Join-Path $skillsDirectory 'muchado'
$referencesDirectory = Join-Path $skillDirectory 'references'
$readmeStartMarker = '<!-- DO NOT EDIT: update-repo-docs convention -->'
$readmeEndMarker = '<!-- END DO NOT EDIT -->'

if (-not (Test-Path -LiteralPath $mainDocPath -PathType Leaf)) {
    throw "Expected main documentation file at $mainDocPath."
}

if (-not (Test-Path -LiteralPath $readmePath -PathType Leaf)) {
    throw "Expected target repository README at $readmePath."
}

function Remove-FrontMatter {
    param([Parameter(Mandatory)][string] $Content)

    return [regex]::Replace($Content, '(?s)^---\r?\n.*?\r?\n---\r?\n?', '', 1)
}

function Remove-IntroductionHeading {
    param([Parameter(Mandatory)][string] $Content)

    return [regex]::Replace($Content, '(?m)^# Introduction\r?\n\r?\n?', '', 1)
}

function Rewrite-MainDocumentationLinks {
    param([Parameter(Mandatory)][string] $Content)

    $content = [regex]::Replace(
        $Content,
        '(\]\()\./README\.md((?:#[^)]+)?\))',
        '$1SKILL.md$2')

    return [regex]::Replace(
        $content,
        '(\]\()\./([^/)#]+\.md)((?:#[^)]+)?\))',
        '$1references/$2$3')
}

function Rewrite-ReferenceDocumentationLinks {
    param([Parameter(Mandatory)][string] $Content)

    $content = [regex]::Replace(
        $Content,
        '(\]\()\./README\.md((?:#[^)]+)?\))',
        '$1../SKILL.md$2')

    return [regex]::Replace(
        $content,
        '(\]\()README\.md((?:#[^)]+)?\))',
        '$1../SKILL.md$2')
}

function Rewrite-ReadmeDocumentationLinks {
    param([Parameter(Mandatory)][string] $Content)

    $content = [regex]::Replace(
        $Content,
        '(\]\()\./README\.md((?:#[^)]+)?\))',
        '$1https://muchado.net/$2')

    return [regex]::Replace(
        $content,
        '(\]\()\./([^/)#]+)\.md((?:#[^)]+)?\))',
        '$1https://muchado.net/$2$3')
}

function Write-Utf8NoBomFile {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $Content
    )

    $encoding = [System.Text.UTF8Encoding]::new($false)
    $normalizedContent = $Content -replace "\r\n?", "`n"
    [System.IO.File]::WriteAllText($Path, ($normalizedContent.TrimEnd() + "`n"), $encoding)
}

function Update-GeneratedReadmeSection {
    param(
        [Parameter(Mandatory)][string] $Content,
        [Parameter(Mandatory)][string] $GeneratedSection
    )

    $normalizedContent = $Content -replace "\r\n?", "`n"
    $generatedBlock = "$readmeStartMarker`n`n$($GeneratedSection.Trim())`n`n$readmeEndMarker"
    $escapedStartMarker = [regex]::Escape($readmeStartMarker)
    $escapedEndMarker = [regex]::Escape($readmeEndMarker)
    $generatedBlockRegex = [regex]::new("(?s)$escapedStartMarker.*?$escapedEndMarker")

    if ([regex]::IsMatch($normalizedContent, $escapedStartMarker)) {
        if (-not [regex]::IsMatch($normalizedContent, $escapedEndMarker)) {
            throw "README contains '$readmeStartMarker' without '$readmeEndMarker'."
        }

        return $generatedBlockRegex.Replace(
            $normalizedContent,
            [System.Text.RegularExpressions.MatchEvaluator] { param($match) $generatedBlock },
            1)
    }

    return $normalizedContent.TrimEnd() + "`n`n$generatedBlock`n"
}

New-Item -ItemType Directory -Force -Path $skillDirectory, $referencesDirectory | Out-Null

$mainBody = Get-Content -Raw -LiteralPath $mainDocPath
$mainBody = Remove-FrontMatter -Content $mainBody
$mainBody = $mainBody.TrimStart([char[]] "`r`n")

$skillBody = Rewrite-MainDocumentationLinks -Content $mainBody

$skillContent = @"
---
name: muchado
description: Use the MuchAdo .NET data-access documentation when answering questions, writing code, or explaining library behavior.
---

$skillBody
"@

Write-Utf8NoBomFile -Path (Join-Path $skillDirectory 'SKILL.md') -Content $skillContent

$readmeSection = Remove-IntroductionHeading -Content $mainBody
$readmeSection = Rewrite-ReadmeDocumentationLinks -Content $readmeSection
$readmeSection = $readmeSection.Trim()
$readmeSection = @"
$readmeSection

For more information, please check out our [comprehensive documentation](https://muchado.net/)!
"@

$readmeContent = Get-Content -Raw -LiteralPath $readmePath
$readmeContent = Update-GeneratedReadmeSection -Content $readmeContent -GeneratedSection $readmeSection
Write-Utf8NoBomFile -Path $readmePath -Content $readmeContent

$sourceReferenceFiles = Get-ChildItem -LiteralPath $docsDirectory -Filter '*.md' -File |
    Where-Object { $_.Name -ne 'README.md' } |
    Sort-Object Name

$expectedReferenceNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($sourceReferenceFile in $sourceReferenceFiles) {
    [void] $expectedReferenceNames.Add($sourceReferenceFile.Name)

    $referenceContent = Get-Content -Raw -LiteralPath $sourceReferenceFile.FullName
    $referenceContent = Remove-FrontMatter -Content $referenceContent
    $referenceContent = $referenceContent.TrimStart([char[]] "`r`n")
    $referenceContent = Rewrite-ReferenceDocumentationLinks -Content $referenceContent

    Write-Utf8NoBomFile -Path (Join-Path $referencesDirectory $sourceReferenceFile.Name) -Content $referenceContent
}

Get-ChildItem -LiteralPath $referencesDirectory -Filter '*.md' -File | ForEach-Object {
    if (-not $expectedReferenceNames.Contains($_.Name)) {
        Remove-Item -LiteralPath $_.FullName
    }
}

Write-Host "Updated MuchAdo repository documentation from docs."