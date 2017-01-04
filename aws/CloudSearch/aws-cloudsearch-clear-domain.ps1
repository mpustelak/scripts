$searchUrl = '[SEARCH_URL]'
$documentUrl = '[DOCUMENT_URL]'
$parser = 'Lucene'
$querySize = 500

function Get-DomainHits()
{
    (Search-CSDDocuments -ServiceUrl $searchUrl -Query "*:*" -QueryParser $parser -Size $querySize).Hits;
}

function Get-TotalDocuments()
{
    (Get-DomainHits).Found
}

function Delete-Documents()
{
    (Get-DomainHits).Hit | ForEach-Object -begin { $batch = '[' } -process { $batch += '{"type":"delete","id":' + $_.id + '},'} -end { $batch = $batch.Remove($batch.Length - 1, 1); $batch += ']' }
       
    Try
    {
        Invoke-WebRequest -Uri $documentUrl -Method POST -Body $batch -ContentType 'application/json'
    }
    Catch
    {
        $_.Exception
        $_.Exception.Message
    }
}

$total = Get-TotalDocuments
while($total -ne 0)
{
    Delete-Documents

    $total = Get-TotalDocuments

    Write-Host 'Documents left:'$total
    # Sleep for 1 second to give CS time to delete documents
    sleep 1
}