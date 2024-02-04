class avvTest : avvBase
{
    $f1='qwerty'
    [hashtable] $f2=@{"f1"="zxc"; "f3"=2}
    [int] $f3=0

    # Если конструкторы не переопределять, тогда доступен только new()
    # Если конструкторы переопределять, тогда доступны только переопределенные
    # Т.е. переопределять все (в данном случае два из avvBase.
    avvTest () : base (){}
    avvTest ([Hashtable]$p) : base ($p){}
    avvTest ([String]$p) : base (){
        $this.f1 = $p
    }
    avvTest ([Int]$p0, [String]$p) : base (){
        $this.f1 = $p
        $this.f3 = $p0
    }
}

$qwerty="qwqwqw"
$qwerty+="asd"

#Export-ModuleMember -Function * -Variable *
