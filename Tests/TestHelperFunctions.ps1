#
# TestHelperFunctions.ps1
#
Function Find-Operator {
        Param($string)
        switch -wildcard ($String) {
            "*~:=*" {return '~:='}
            "*:~=*" {return ':~='}
            "*~=*"  {return '~='}
            "*:=*"  {return ':='}
            "*=*"   {return '='}
            "*=~*"  {throw 'error 400'}
            "*=:*"  {throw 'error 400'}
            "*=~:*" {throw 'error 400'}
            "*=:~*" {throw 'error 400'}
            default {throw 'error 400'}
        }
    }
Function MatchAnyValue {
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [object]$inputObject,
        
        [string]$matchString,

        [string]$Operator
    )
    BEGIN{}
    PROCESS{
        $AllValues = $($inputobject | gm -MemberType NoteProperty | %{$inputobject.$($_.name).ToString()})
        $AllValuesString = $AllValues -join ';'
        Switch ($Operator) {
            '=' {return $($AllValues -ccontains $matchString)}
            ':=' {return $($AllValues -icontains $matchString)}
            '~:=' {return $($AllValuesString -ilike "*$matchString*")}
            '~=' {return $($AllValuesString -clike "*$matchString*")}
        }
    }
    END{}
}
Function Mock-InfobloxGet {
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [uri]$uri
    )
    BEGIN{}
    PROCESS{
    If ($Uri.segments[0] -ne '/'){throw $URI}
    If ($uri.segments[1] -ne 'wapi/'){throw $URI}
    If ($uri.segments[2] -notlike 'v*.*/'){throw $Uri}
    $RecordType = $uri.segments[3]
    $Filters = $uri.query.replace('?','').split('&')
    If ($RecordType -eq 'search'){
		$Return = $Script:recordlist
    } else {
        $ref = $uri.segments[3..6] -join ''
    	$Return = $script:recordlist | Where-Object{($_._ref -like "$ref/*") -or ($_._ref -eq $ref)}
    }
	
    $ReturnFields = @('_ref')
    Foreach ($filter in $Filters){
        If ($filter -like "_return_fields=*"){
            $ReturnFields += $filter.replace('_return_fields=','').split(',')
        } elseif ($filter -like "_max_results=*"){
            $MaxResults = $filter.replace('_max_results=','')
		} elseif ($filter -like "objtype=*") {
			$Operator = '='
            [string]$QueryValue = $Filter.split($operator)[-1].replace('%20',' ')
            $Return = $Return | ?{$_._ref -like "$queryvalue*"}
        } elseif ($filter -like "search_string*") {
            Try {
                $Operator = Find-Operator -string $Filter
            } Catch {
                Throw $URI
            }
            [string]$QueryValue = $Filter.split($operator)[-1].replace('%20',' ')
            If ($QueryValue -eq 'False'){
                [bool]$QueryValue = $False
            }
            $Return = $Return | ?{MatchAnyValue -inputobject $_ -matchstring $queryvalue -operator $Operator}
        } elseif ($Filter -like "address=*") {
            $operator = '='
            [string]$QueryValue = $Filter.split($operator)[-1].replace('%20',' ')
            $Return = $Return | ?{MatchAnyValue -inputobject $_ -matchstring $QueryValue -operator '='}
        } elseif ($Filter -notlike $Null) {
            Try {
                $Operator = Find-Operator -string $Filter
            } Catch {
                Throw $URI
            }
            [string]$QueryField = $Filter.split($operator)[0]
            [string]$QueryValue = $Filter.split($operator)[-1].replace('%20',' ')
            If ($QueryValue -eq 'False'){
                [bool]$QueryValue = $False
            }
            Switch ($Operator) {
                '=' {
						If ($QueryField -match "^\*"){
							$Return = $Return | ?{$_.extattrs.$($QueryField.replace('*','')).value -ceq $QueryValue}
						} else {
							$Return = $Return | ?{$_.$QueryField -ceq $QueryValue}
						}
						continue
					}
                ':=' {
						If ($QueryField -match "^\*"){
							$Return = $Return | ?{$_.extattrs.$($QueryField.replace('*','')).value -ieq $QueryValue}
						} else {
							$Return = $Return | ?{$_.$QueryField -ieq $QueryValue}
						}
						continue
					}
                '~:=' {
						If ($QueryField -match "^\*"){
							$Return = $Return | ?{$_.extattrs.$($QueryField.replace('*','')).value -ilike "*$QueryValue*"}
						} else {
							$Return = $Return | ?{$_.$QueryField -ilike "*$QueryValue*"}
						}
						continue
					}
                ':~=' {
						If ($QueryField -match "^\*"){
							$Return = $Return | ?{$_.extattrs.$($QueryField.replace('*','')).value -ilike "*$QueryValue*"}
						} else {
							$Return = $Return | ?{$_.$QueryField -ilike "*$QueryValue*"}
						}
						continue
					}
                '~=' {
						If ($QueryField -match "^\*"){
							$Return = $Return | ?{$_.extattrs.$($QueryField.replace('*','')).value -clike "*$QueryValue*"}
						} else {
							$Return = $Return | ?{$_.$QueryField -clike "*$QueryValue*"}
						}
						continue
					}
            }
        }
    }
    If ($MaxResults){
        $Return = $Return | select -First $MaxResults
    }
    If ($ReturnFields) {
        $Return = $return | select $ReturnFields
    }
    return $Return
    }
    END{}
}
Function Mock-InfobloxDelete {
	Param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[uri]$uri
	)
	BEGIN{}
	PROCESS{
		If ($URI -eq "https://$script:gridmaster/wapi/$script:wapiversion/$($URI.Segments[3..5] -join '')"){
			$Script:Recordlist = $Script:Recordlist | where-object{$_._ref -ne $($URI.Segments[3..5] -join '')}
			return $($URI.Segments[3..5] -join '')
		} else {
			Throw $URI
		}
	}
	END{}
}
Function Mock-InfobloxPost {
	Param(
		[Parameter(Mandatory=$True)]
		[uri]$Uri,

		[Parameter(Mandatory=$True)]
		$Body
	)
	If ($Uri.segments[0] -ne '/'){throw $URI}
	If ($uri.segments[1] -ne 'wapi/'){throw $URI}
	If ($uri.segments[2] -notlike 'v*.*/'){throw $Uri}
	$RecordType = $uri.segments[3]
	$Refcode = $('abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() | get-random -count 20) -join ''
	$properties = $Body

	If ($RecordType -eq 'fixedaddress'){
		If(! $properties.Network_View){$properties.network_view = 'default'}
	} else {
		If (! $properties.View){$properties.View = 'default'}
	}

	Switch ($RecordType) {
		'record:ptr'{
						 If (! $properties.Name){
							$Parts = $properties.ipv4addr.split('.')
							$name = "$($parts[3]).$($parts[2]).$($Parts[1]).$($Parts[0]).in-addr.arpa"
							$Properties += @{'name' = $Name}
						 }
					}
		'fixedaddress'{
						If($properties.match_client -eq 'RESERVED'){$properties.MAC = '00:00:00:00:00:00'}
			          }

	}
	If ((! $Properties.NetworkView) -and ($recordtype -eq 'fixedaddress')){
		$properties.networkview = 'default'
	} elseif (! $Properties.view){
		$Properties.view = 'default'
	}
	If ((! $properties.Name) -and ($Recordtype -eq 'record:ptr')){
		$Parts = $properties.ipv4addr.split('.')
		$name = "$($parts[3]).$($parts[2]).$($Parts[1]).$($Parts[0]).in-addr.arpa"
		$Properties += @{'name' = $Name}
	}
	$_Ref = "$RecordType$Refcode"
	$Properties += @{'_ref' = $_Ref}
	$Script:Recordlist += $(New-Object PSObject -Property $Properties)
	return $_Ref
}
Function Mock-InfobloxPut {
	Param(
		[Parameter(Mandatory=$True)]
		[uri]$Uri,

		[Parameter(Mandatory=$True)]
		$Body
	)
	If ($Uri.segments[0] -ne '/'){throw $URI}
	If ($uri.segments[1] -ne 'wapi/'){throw $URI}
	If ($uri.segments[2] -notlike 'v*.*/'){throw $Uri}
	$RecordType = $uri.segments[3]
	$RefCode = $Uri.segments[4].Split(':')[0]
	$_Ref = "$RecordType$Refcode"
	$OldRecord = $Script:Recordlist | where-object{$_._ref -like "$_Ref*"}
	If ($OldRecord){
		$NewRecordProperties = Merge-RecordData -Record1 $OldRecord -Record2 $($Body | convertfrom-JSON)
		$Script:Recordlist = $Script:Recordlist | where-object{$_._ref -notlike "$_Ref*"}
		$Script:Recordlist += New-object psobject -property $NewRecordProperties
		return $OldRecord._ref
	} else {
		Throw $URI
	}
}
Function Merge-RecordData {
	Param(
		[object]$Record1,
		[object]$Record2
	)
	$Records = @($Record1,$Record2)
	$HashTable = $Null
	Foreach ($object in $Records){
		Foreach ($Property in $($Object | gm | ?{$_.membertype -eq 'NoteProperty'})){
			$PropertyName = $Property.Name
			If ($PropertyName -eq 'extattrs'){
				$Hashtable.extattrs = $object.extattrs
			}
			If ($Propertyname -eq 'extattrs+'){
				$EAName = ($object."extattrs+" | gm | ?{$_.membertype -eq 'NoteProperty'}).Name
				$EAValue = $object."extattrs+".$EAName.value
				$newEA = new-object psobject -Property @{name=$EAName;value=$EAValue} | convertfrom-extattrsarray
				If ($HashTable.extattrs.$EAName){
					$HashTable.extattrs.$EAName.Value = $EAValue
				} else {
					If (! $HashTable.extattrs){
						$Hashtable += @{extattrs = $newEA}
					} else {
						$HashTable.extattrs | add-member -MemberType NoteProperty -Name $EAName -Value $newEA.$EAName
					}
				}

			} elseif ($PropertyName -eq 'extattrs-'){
				$EAName = ($object."extattrs-" | gm | ?{$_.membertype -eq 'NoteProperty'}).Name
				$HashTable.extattrs.psobject.properties.remove($EAName)
			} else {
				$PropertyValue = $object.$($Property.Name)
				If ($HashTable.Keys -contains $PropertyName){
					$HashTable."$PropertyName" = $PropertyValue
				} else {
					$Hashtable += @{$PropertyName = $PropertyValue}
				}

			}
		}
		#$Hashtable | Out-GridView
	}
	$HashTable
}
