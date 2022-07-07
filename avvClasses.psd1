#
# �������� ������ ��� ������ "classes".
#
# �������: vovka
#
# ���� ��������: 25.06.2022
#

@{

# ���� ������ �������� ��� ��������� ������, ��������� � ���� ����������.
    RootModule = 'avvClasses.psm1'

    # ����� ������ ������� ������.
    ModuleVersion = '2.2.0'

    # �������������� ������� PSEditions
    # CompatiblePSEditions = @()

    # ���������� ������������� ������� ������
    GUID = '241d90be-1350-4722-acb5-4fcc1d822f53'

    # ����� ������� ������
    Author = 'Alexeev Vladimir'

    # ��������, ��������� ������ ������, ��� ��� ���������
    CompanyName = 'Home'

    # ��������� �� ��������� ������ �� ������
    Copyright = '(c) 2022 Alexeev Vladimir. ��� ����� ��������.'

    # �������� ������� ������� ������
    # Description = ''

    # ����������� ����� ������ ����������� Windows PowerShell, ����������� ��� ������ ������� ������
    PowerShellVersion = '5.0'

    # ��� ���� Windows PowerShell, ������������ ��� ������ ������� ������
    # PowerShellHostName = ''

    # ����������� ����� ������ ���� Windows PowerShell, ����������� ��� ������ ������� ������
    # PowerShellHostVersion = ''

    # ����������� ����� ������ Microsoft .NET Framework, ����������� ��� ������� ������. ��� ������������ ���������� ������������� ������ ��� ������� PowerShell, ���������������� ��� �����������.
    # DotNetFrameworkVersion = ''

    # ����������� ����� ������ ����� CLR (������������ ����� ����������), ����������� ��� ������ ������� ������. ��� ������������ ���������� ������������� ������ ��� ������� PowerShell, ���������������� ��� �����������.
    # CLRVersion = ''

    # ����������� ���������� (���, X86, AMD64), ����������� ��� ����� ������
    # ProcessorArchitecture = ''

    # ������, ������� ���������� ������������� � ���������� ����� ����� ��������������� ������� ������
    # RequiredModules = @()

    # ������, ������� ������ ���� ��������� ����� ��������������� ������� ������
    # RequiredAssemblies = @()

    # ����� �������� (PS1), ������� ����������� � ����� ���������� ������� ����� �������� ������� ������.
    # ScriptsToProcess = @()

    # ����� ���� (.ps1xml), ������� ����������� ��� ������� ������� ������
    # TypesToProcess = @()

    # ����� ������� (PS1XML-�����), ������� ����������� ��� ������� ������� ������
    # FormatsToProcess = @()

    # ������ ��� ������� � �������� ��������� ������� ������, ���������� � ��������� RootModule/ModuleToProcess
    # NestedModules = @()

    # � ����� ����������� ����������� ������������������ ������� ��� �������� �� ����� ������ �� ���������� �������������� ����� � �� ������� ������. ����������� ������ ������, ���� ��� ������� ��� ��������.
    FunctionsToExport = @('Get-Logger', 'Get-IniCFG', 'Get-AvvClass', 'Info-avvTypesv5')
    #FunctionsToExport = '*'

    # � ����� ����������� ����������� ������������������ ���������� ��� �������� �� ����� ������ �� ���������� �������������� ����� � �� ������� ������. ����������� ������ ������, ���� ��� ����������� ��� ��������.
    CmdletsToExport = @()

    # ���������� ��� �������� �� ������� ������
    VariablesToExport = '*'

    # � ����� ����������� ����������� ������������������ ���������� ��� �������� �� ����� ������ �� ���������� �������������� ����� � �� ������� ������. ����������� ������ ������, ���� ��� ����������� ��� ��������.
    AliasesToExport = @()

    # ������� DSC ��� �������� �� ����� ������
    # DscResourcesToExport = @()

    # ������ ���� �������, �������� � ����� ������� ������
    # ModuleList = @()

    # ������ ���� ������, �������� � ����� ������� ������
    # FileList = @()

    # ������ ������ ��� �������� � ������, ��������� � ��������� RootModule/ModuleToProcess. �� ����� ����� ��������� ���-������� PSData � ��������������� ����������� ������, ������� ������������ � PowerShell.
    PrivateData = @{

        PSData = @{

        # ����, ���������� � ����� ������. ��� �������� � ������������ ������ � ������-����������.
        # Tags = @()

        # URL-����� �������� ��� ����� ������.
        # LicenseUri = ''

        # URL-����� �������� ���-����� ��� ����� �������.
        # ProjectUri = ''

        # URL-����� ������, ������� ������������ ���� ������.
        # IconUri = ''

        # ������� � ������� ����� ������
        # ReleaseNotes = ''

        } # ����� ���-������� PSData

    } # ����� ���-������� PrivateData

    # ��� URI ��� HelpInfo ������� ������
    # HelpInfoURI = ''

    # ������� �� ��������� ��� ������, ���������������� �� ����� ������. �������������� ������� �� ��������� � ������� ������� Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}