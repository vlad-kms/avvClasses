class avvBase{
    avvBase ([Hashtable]$Params) : base () {
        $properties = $this | Get-Member -MemberType Properties | Select-Object -ExpandProperty 'Name';

    }
}