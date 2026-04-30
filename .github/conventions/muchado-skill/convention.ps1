Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (Get-Location).Path
$docsDirectory = Join-Path $repoRoot 'docs'
$mainDocPath = Join-Path $docsDirectory 'README.md'
$skillDirectory = Join-Path $repoRoot 'skills/muchado'
$referencesDirectory = Join-Path $skillDirectory 'references'

if (-not (Test-Path -LiteralPath $mainDocPath -PathType Leaf)) {
    throw "Expected main documentation file at $mainDocPath."
}

function Remove-FrontMatter {
    param([Parameter(Mandatory)][string] $Content)

    return [regex]::Replace($Content, '(?s)^---\r?\n.*?\r?\n---\r?\n?', '', 1)
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

function Write-Utf8NoBomFile {
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $Content
    )

    $encoding = [System.Text.UTF8Encoding]::new($false)
    $normalizedContent = $Content -replace "\r\n?", "`n"
    [System.IO.File]::WriteAllText($Path, ($normalizedContent.TrimEnd() + "`n"), $encoding)
}

New-Item -ItemType Directory -Force -Path $skillDirectory, $referencesDirectory | Out-Null

$mainBody = Get-Content -Raw -LiteralPath $mainDocPath
$mainBody = Remove-FrontMatter -Content $mainBody
$mainBody = $mainBody.TrimStart([char[]] "`r`n")
$mainBody = Rewrite-MainDocumentationLinks -Content $mainBody

$skillContent = @"
---
name: muchado
description: Use the MuchAdo .NET data-access documentation when answering questions, writing code, or explaining library behavior.
---

$mainBody
"@

Write-Utf8NoBomFile -Path (Join-Path $skillDirectory 'SKILL.md') -Content $skillContent

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

Write-Host "Built MuchAdo skill at skills/muchado from docs."