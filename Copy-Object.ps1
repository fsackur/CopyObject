function Copy-Object
{
    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [psobject]$InputObject,

        [uint16]$Depth = 1
    )

    process
    {
        $OutputObject = [pscustomobject]::new()
        $OutputObject.PSTypeNames.Clear()
        $InputObject.PSTypeNames.ForEach({$OutputObject.PSTypeNames.Add($_)})

        $InputObject.PSObject.Properties.ForEach({

            $Value = $_.Value
            $Type = $Value.GetType()

            if ($Depth -gt 1 -and -not $Type.IsValueType)
            {
                $Value = switch ($Type)
                {
                    ([string]) {$Value; break}
                    ([datetime]) {[datetime]::new($Value.Ticks); break}
                    ([decimal]) {Write-Warning "NotImplemented yet"}
                    default {Copy-Object -InputObject $Value -Depth ($Depth - 1)}
                }
            }

            $MemberSplat = @{
                InputObject = $OutputObject
                MemberType  = [System.Management.Automation.PSMemberTypes]::NoteProperty
                Name        = $_.Name
                Value       = $_.Value
                TypeName    = $_.TypeNameOfValue
            }

            
            

            Add-Member @MemberSplat
        })

        return $OutputObject
    }
}
