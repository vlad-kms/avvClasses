class avvBase {
    avvBase ()
    {}

    # входящий hashtable:
    #   @{
    #       '_obj_'=@{} - значения для свойств объекта
    #       '_obj_add_'=@{} - поля для добавления в объект
    #       '_obj_add_value_'=@{} - значения для добавления к текущим значениям полей объекта
    #   }
    avvBase ([Hashtable]$params)
    {
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
                $this | Add-Member -MemberType NoteProperty -Name $_ -Value $params.$keyObj[$_]
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
    }

    [String] ToJson()
    {
        return ($this | ConvertTo-Json -Depth 1);
    }
}