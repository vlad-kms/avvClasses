import-module D:\Tools\~scripts.ps\avvClasses\avvClasses
#. D:\Tools\~scripts.ps\avvClasses\classes\avvBase.ps1
#. D:\Tools\~scripts.ps\avvClasses\classes\classCFG.ps1

(get-avvClass -ClassName JsonCFG -Params @{_new_=@{Filename="E:\!my-configs\configs\src\dns-api\config.json";ErrorAsException=$true}} -Verbose)
