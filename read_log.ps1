
$content = Get-Content analysis_v4.txt -Encoding UTF8
$content | Select-String "error"
