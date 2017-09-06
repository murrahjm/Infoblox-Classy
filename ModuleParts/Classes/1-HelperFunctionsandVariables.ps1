#Variables
#Helper Functions
Function ConvertTo-PTRName {
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [ipaddress]$IPAddress
    )
    BEGIN{}    
    PROCESS{
        $Octets = $IPAddress.IPAddressToString.split('.')
        $name = "$($octets[3]).$($octets[2]).$($octets[1]).$($octets[0]).in-addr.arpa"
        return $name
    }
    END{}
}
Function ConvertFrom-PTRName {
	Param(
		[Parameter(mandatory=$True,ValueFromPipeline=$True)]
		[String]$PTRName
	)
	BEGIN{}
	PROCESS{
		$Octets = $PTRName.split('.')
		[IPAddress]$IPAddress = "$($octets[3]).$($octets[2]).$($octets[1]).$($octets[0])"
		return $IPAddress
	}
	END{}
}
Function ConvertTo-ExtAttrsArray {
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [Object]$extattrs
    )
    BEGIN{}
    PROCESS{
        If ($Extattrs) {
            $ExtAttrList = $Extattrs | get-member | where-object{$_.MemberType -eq 'NoteProperty'}
            Foreach ($ExtAttr in $ExtAttrList){
                $objExtAttr = New-object PSObject -Property @{
                    Name = $Extattr.Name
                }
                Foreach ($property in $($ExtAttrs.$($Extattr.Name) | get-member | where-object{$_.membertype -eq 'noteproperty'})) {
                    $objExtAttr | Add-Member -MemberType NoteProperty -name $property.Name -Value $($Extattrs.$($extattr.name).$($property.name))
                }
                $objextattr
            }
        } else {
            return $Null
        }
    }
    END{}
}
Function ConvertFrom-ExtAttrsArray {
	Param (
		[Parameter(ValueFromPipeline=$True)]
		[object]$ExtAttrib
	)
	BEGIN{}
	PROCESS{
		$objextattr = New-Object psobject -Property @{}
		Foreach ($extattr in $extattrib){
			$Value = new-object psobject -Property @{value=$ExtAttrib.value}
			$objextattr | Add-Member -MemberType NoteProperty -Name $($ExtAttrib.Name) -Value $Value
		}
		$objextattr
	}
	END{}
}
Function SearchstringToIBQuery {
    param ($SearchString)
    $Words = $Searchstring.split(' ')
    $property = $words[0]
    $Operator = $words[1]
    $Value = $words[2..$($words.length -1)] -join ' ' -replace "`"" -replace "`'"
    If ($operator -eq '-eq'){$iboperator = ':='}
    If ($operator -eq '-like'){$iboperator = '~:='}
    $IBQueryString = "*$property$iboperator$value&"
    return $IBQueryString
}
