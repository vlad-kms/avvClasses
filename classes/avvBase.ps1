enum FlagAddHashtable {
    AddOnly = 1
    Merge   = 2
}

class avvBase : Object {
#class avvBase : PSCustomObject {
    hidden [FlagAddHashtable] $AddOrMerge

    <##>
    avvBase ()
    {
        $this.AddOrMerge = [FlagAddHashtable]::Merge
    }

    <#########################################################
    входящий hashtable:
        @{
            '_obj_'=@{} - значения для свойств объекта.
                        Заменить значение ключа, если такой ключ есть в объекте
            '_obj_add_'=@{} - поля для добавления в объект
                        Добавить ключ и значение ключа с помощью Add-Member -MemberType NoteProperty
            '_obj_add_value_'=@{} - значения для добавления к текущим значениям полей объекта
        }
    #########################################################>
    avvBase ([Hashtable]$params) {
        $this.initFromHashtable($params)
    }


    <# MEMBERS +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #>
    <##>
    [boolean] isAvvClass () {
        return $True
    }

    <##>
    [void]initFromHashtable([Hashtable]$params) {
        $keyObj = '_obj_';
        if ( $params.Contains($keyObj))
        {
            foreach ($key in ($this | Get-Member -Force -MemberType Properties | Select-Object -ExpandProperty Name))
            {
                if ($params.$keyObj.Contains($key)) {
                    $this.$key = $params.$keyObj.$key;
                }
            }
        }
        $keyObj = '_obj_add_';
        if ( $params.Contains($keyObj))
        {
            $params.$keyObj.Keys.foreach({
                #$this[$_] = $params.$keyObj[$_];
                #Write-Host "$($_) === $($params.$keyObj[$_]))"
                #$this | Add-Member -MemberType NoteProperty -Name $_ -Value $params.$keyObj[$_]
                $this | Add-Member NotePropertyName $_ -NotePropertyValue $params.$keyObj[$_]
            })
        }
        $keyObj = '_obj_add_value_';
        if ( $params.Contains($keyObj))
        {
            foreach ($key in ($this | Get-Member -Force -MemberType Properties | Select-Object -ExpandProperty Name))
            {
                if ($params.$keyObj.Contains($key)) {
                    $this.$key += $params.$keyObj.$key;
                }
            }
        }
        $keyObj = '_new_';
        if ( $params.Contains($keyObj)) {
            $this.addHashtable($params.$keyObj, $this, [FlagAddHashtable]::Merge)
        }
    }

    <##>
    [bool] ExistsProperty($Obj, $Key) {
        $result = $false
        try {
            if ($this.isHashtable($Obj)) {
                $result = $Obj.ContainsKey($Key)
            } else {
                $result = ($null -ne ($Obj|Get-Member $Key))
            }
        }
        catch {
            $result = $False
        }
        return $result
    }

    <##>
    [bool] addHashtable([hashtable]$Source) {
        return $this.addHashtable($Source, $this, $this.AddOrMerge)
    }
    [bool] addHashtable([hashtable]$Source, $Dest) {
        return $this.addHashtable($Source, $Dest, $this.AddOrMerge)
    }
    [bool] addHashtable([hashtable]$Source, [FlagAddHashtable]$Action) {
        return $this.addHashtable($Source, $this, $Action)
    }

    <##>
    [bool] addHashtable([hashtable]$Source, $Dest, [FlagAddHashtable]$Action) {
        $result = $false
        try {
            if ($null -eq $Dest) {throw "Объект назначения не может быть null"}
            foreach($Key in $Source.Keys) {
                if ($this.ExistsProperty($Dest, $Key)) {
                    # ключ есть в объекте назначения
                    Write-Verbose "Ключ $($Key) ЕСТЬ в $($Dest) и флаг $($Action)"
                    switch ($Action) {
                        ([FlagAddHashtable]::AddOnly) {
                            Write-Verbose "В объекте Dest есть ключ $Key. Флаг Action = $Action. Ничего не добавляется, ничего не изменяется"
                        }
                        ([FlagAddHashtable]::Merge) {
                            Write-Verbose "В объекте Dest есть ключ $Key. Флаг Action = $Action. Тип значения ключа: $($Dest.$Key.GetType())"
                            if ($this.isCompositeType($Dest.$Key) -and $this.isCompositeType($Source.$Key)) {
                                # Dest.Key имеет тип Hashtable или avvBase
                                Write-Verbose "Рекурсивный вызов с Source.$($Key),  Dest.$($Key), $Action"
                                $this.addHashtable($Source.$Key, $Dest.$Key, $Action)
                            } else {
                                Write-Verbose "В Dest.Key записали $($Source.$Key)"
                                $Dest.$Key = $Source.$Key
                            }
                        }
                        Default {
                            throw "Неверное значения $($Action)"
                        }
                    } ### switch ($Action) {
                } else {
                    # ключа нет в объекте назначения
                    Write-Verbose "=== Здесь: $($key) нет в $($Dest) и флаг $($action)"
                    if ( $this.isHashtable($Dest)) {
                        # добавить к Hashtable
                        Write-Verbose "Добавить $($Key) к Hashtable $($Dest)"
                        $Dest.Add($key, $Source.$key)
                    #} elseif ( ($Dest -is [Object]) -or ($Dest -is [PSObject]) -or ($Dest -is [PSCustomObject]) ) {
                    } elseif ( $this.isObject($Dest) ) {
                        Write-Verbose "Add-Member к типам Object, PSObject, PSCustomObject : $($Key) = $($Source.$Key)"
                        $Dest | Add-Member -NotePropertyName $key -NotePropertyValue $Source.$key
                    } else {
                        Write-Verbose "Не можем добавить $($Key) к Dest типа $($Dest.GetType())"
                    }
                }
            }
            $result=$True
        }
        catch {
            $result = $false
        }
        return $result
    }

    <##>
     [String] ToJson()
    {
        return ($this | ConvertTo-Json -Depth 100);
    }

    <##>
    ################## isHashtable ###########################
    [bool] isHashtable($value)
    {
        #return ($value -is [Hashtable]) -or ($value -is [System.Collections.Specialized.OrderedDictionary]);
        $result = ($value -is [System.Collections.IDictionary]);
        return $result
    }

    <##>
    [bool] isObject($Value) {
        #return ($value -is [Hashtable]) -or ($value -is [System.Collections.Specialized.OrderedDictionary]);
        #$result= ($Value -is [System.Object] -or $Value -is [PSObject] -or $Value -is [PSCustomObject])
        $result = $Value -is [avvBase]
        return $result
    }

    <##>
    [bool] isCompositeType($Value) {
        $result= ($this.isHashtable($Value) -or 
                $this.isObject($Value))
        return $result
    }

}