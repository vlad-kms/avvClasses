class avvBase{
    avvBase ()
    {}
    avvBase ([Hashtable]$params)
    {
        $keyObj = '_obj_';
        if ( $params.Contains($keyObj))
        {
            foreach ($key in ($this | Get-Member -Force -MemberType Properties | Select-Object -ExpandProperty Name))
            {
                $this.$key = $params.$keyObj.$key;
            }
        }
    }
}