<#
.Synopsis
	Get-IBExtensibleAttributeDefinition retreives objects of type ExtAttrsDef from the Infoblox database.
.DESCRIPTION
	Get-IBExtensibleAttributeDefinition retreives objects of type ExtAttrsDef from the Infoblox database.  Extensible Attribute Definitions define the type of extensible attributes that can be attached to other records.  Parameters allow searching by Name, type, and commentAlso allows retrieving a specific record by reference string.  Returned object is of class type IB_ExtAttrsDef.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The attribute definition name to search for.  Can be full or partial name match depending on use of the -Strict switch
.PARAMETER Type
	The attribute value type to search for.  Valid values are:
        •DATE
        •EMAIL
        •ENUM
        •INTEGER
        •STRING
        •URL

.PARAMETER MaxResults
	The maximum number of results to return from the query.  A positive value will truncate the results at the specified number.  A negative value will throw an error if the query returns more than the specified number.
.PARAMETER Comment
	A string to search for in the comment field of the extensible attribute definition.  Will return any record with the matching string anywhere in the comment field.  Use with -Strict to match only the exact string in the comment.
.PARAMETER Strict
	A switch to specify whether the search of the name or comment field should be exact, or allow partial word searches or regular expression matching.
.PARAMETER _Ref
	The unique reference string representing the extensible attribute definition.  String is in format <recordtype>/<uniqueString>:<Name>.  Value is assigned by the Infoblox appliance and returned with and find- or get- command.
.EXAMPLE
	Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -Name 'Site'

	This example retrieves all extensible attribute definitions with name beginning with the word Site
.EXAMPLE
	Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -comment 'Test Comment' -Strict

	This example retrieves all extensible attribute definitions with the exact comment 'test comment'
.EXAMPLE
	Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -_Ref 'extensibleattributedef/2ifnkqoOKFNOFkldfjqfko3fjksdfjld:extattr2'

	This example retrieves the single extensible attribute definition with the assigned reference string
.EXAMPLE
	Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -name extattr2 | Remove-IBRecord

	This example retrieves the extensibleattributedefinition with name extattr2, and deletes it from the infoblox database.  Note that some builtin extensible attributes cannot be deleted.
.EXAMPLE
	Get-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -comment 'old comment' -Strict | Set-IBDNSARecord -comment 'new comment'
	
	This example retrieves all extensible attribute definitions with a comment of 'old comment' and replaces it with 'new comment'
.INPUTS
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_ExtAttrsDef
#>
Function Get-IBExtensibleAttributeDefinition {
	[CmdletBinding(DefaultParameterSetName = 'byQuery')]
	Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
        [System.Management.Automation.Credential()]
		$Credential,

		[Parameter(ParameterSetName='byQuery')]
		[String]$Name,

		[Parameter(ParameterSetName='byQuery')]
        [ValidateSet('Date','Email','Enum','Integer','String','URL')]
		[String]$Type,

		[Parameter(ParameterSetName='byQuery')]
		[String]$Comment,

		[Parameter(ParameterSetName='byQuery')]
        [Switch]$Strict,

		[Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byref')]
		[String]$_ref,

        [Int]$MaxResults
	)
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $gridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView
        } Catch {
            Write-error "Unable to connect to Infoblox device $gridmaster.  Error code:  $($_.exception)" -ea Stop
        }
        If ($View){
            Write-Verbose "$FunctionName`:  Validating View parameter against list from Infoblox device"
            If ($IBViews.name -cnotcontains $View){
                $ViewList = $ibviews.name -join ', '
                write-error "Invalid data for View parameter.  Options are $ViewList" -ea Stop
            }
        }
    }
	PROCESS{
		If ($pscmdlet.ParameterSetName -eq 'byQuery') {
			Write-Verbose "$FunctionName`:  Performing query search for extensible attribute definitions"
			[IB_extattrsdef]::Get($Gridmaster,$Credential,$Name,$Type,$Comment,$Strict,$MaxResults)
		} else {
			Write-Verbose "$FunctionName`: Querying $gridmaster for extensible attribute definitions with reference string $_ref"
			[IB_extattrsdef]::Get($Gridmaster, $Credential, $_ref)
		}
	}
	END{}
}