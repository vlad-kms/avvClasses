class avvTest : avvBase
{
    [string]$f1='qwerty'

    # Если конструкторы не переопределять, тогда доступен только new()
    # Если конструкторы переопределять, тогда доступны только переопределенные
    # Т.е. переопределять все (в данном случае два из avvBase.
    avvTest () : base (){}
    avvTest ([Hashtable]$p) : base ($p){}
    avvTest ([String]$p) : base (){
        $this.f1 = $p
    }
}

$qwerty="qwqwqw"
$qwerty+="asd"

#Export-ModuleMember -Function * -Variable *
