Function Get-SynoSid {
	param(	[string]$baseUrl,
			[PSCredential]$cred)
		
	$authApi = 'SYNO.API.Auth'
	$req = @{
		body = @{
			api = 'SYNO.API.Info'
			method = 'Query'
			version = '1'
			query = $authAPI
		}
		uri = "$($baseUrl)/webapi/query.cgi"
	}
	$resp = Invoke-RestMethod @req
	
	if (!$resp.success) {
		Add-Member -inputObject $resp -notePropertyName 'Request' -notePropertyValue $req
		Throw $resp
	}
	
	
	$req = @{
		body = @{
			api = $resp.data | gm -type NoteProperty | % Name
			method = 'Login'
			version = $resp.data.$authAPI.maxVersion
			account = $cred.userName
			passwd = $cred.getNetworkCredential().password
			session = 'SurveillanceStation'
			format = 'sid'
		}
		uri = "$($baseUrl)/webapi/$($resp.data.$authAPI.path)"
	}
	$resp = Invoke-RestMethod @req
	
	if (!$resp.success) {
		Add-Member -inputObject $resp -notePropertyName 'Request' -notePropertyValue $req
		Throw $resp
	}
	return $resp.data.sid
}

Function Revoke-SynoId {
	param(	[string]$baseUrl,
			[string]$sid)
			
	$authApi = 'SYNO.API.Auth'
	$req = @{
		body = @{
			api = 'SYNO.API.Info'
			method = 'Query'
			version = '1'
			query = $authAPI
		}
		uri = "$($baseUrl)/webapi/query.cgi"
	}
	$resp = Invoke-RestMethod @req
	
	if (!$resp.success) {
		Add-Member -inputObject $resp -notePropertyName 'Request' -notePropertyValue $req
		Throw $resp
	}
	
	$req = @{
		body = @{
			api = $resp.data | gm -type NoteProperty | % Name
			method = 'Logout'
			version = $resp.data.$authAPI.maxVersion
			_sid = $sid
			session = 'SurveillanceStation'
		}
		uri = "$($baseUrl)/webapi/$($resp.data.$authAPI.path)"
	}
	$resp = Invoke-RestMethod @req
	
	if (!$resp.success) {
		Add-Member -inputObject $resp -notePropertyName 'Request' -notePropertyValue $req
		Throw $resp
	}
	return $resp
}

Function Get-SynoResUsage {
	param(	[string]$sid,
			[string]$baseUrl)

	$query = @{
		uri = "$($baseUrl)/webapi/entry.cgi"
		Method = "POST"
		Body = @{
			stop_when_error = 'false'
			mode = 'parallel' #because the compound property is an array that might contain several api calls
			compound = ConvertTo-Json -compress -inputObject @( @{
				api = 'SYNO.Core.System.Utilization'
				method = 'get'
				version = 1
				type = 'current'
				resource = @('cpu','memory','network')
			})
			api = 'SYNO.Entry.Request'
			method = 'request'
			version = 1
			_sid = $sid
		}
	}
	
	$resp = Invoke-RestMethod @query
	
	if ($resp.data.has_fail) {
		Add-Member -inputObject $resp -notePropertyName 'Request' -notePropertyValue $query
		Throw $resp
	}
	
	return $resp.data.result.data
}

Function Set-SynoLedBrightness {
	param(	[string]$sid,
			[string]$baseUrl,
			[ValidateRange(0,3)][int]$brightness)

	$query = @{
		uri = "$($baseUrl)/webapi/entry.cgi"
		Method = "POST"
		Body = @{
			stop_when_error = 'false'
			mode = "sequential"
			compound = ConvertTo-Json -compress -inputObject @( @{
				api = "SYNO.Core.Hardware.Led.Brightness"
				method = "set"
				version = "1"
				led_brightness = $brightness
				schedule = "111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"
			}, @{
				api = "SYNO.Core.Hardware.Led.Brightness"
				method = "get"
				version = 1
			})
			api = "SYNO.Entry.Request"
			method = 'request'
			version = 1
			_sid = $sid
		}
	}
	
	$resp = Invoke-RestMethod @query
	
	if ($resp.data.has_fail) {
		Add-Member -inputObject $resp -notePropertyName 'Request' -notePropertyValue $query
		Throw $resp
	}
	return $resp.data.result
}

Function Get-SynoVMMGuests {
	param(	[string]$sid,
			[string]$baseUrl)

	$query = @{
		uri = "$($baseUrl)/webapi/entry.cgi"
		Method = "POST"
		Body = @{
			stop_when_error = 'false'
			mode = 'parallel' #because the compound property is an array that might contain several api calls
			compound = ConvertTo-Json -compress -inputObject @( @{
				api = 'SYNO.Virtualization.Guest'
				method = 'list'
				version = 1
			})
			api = 'SYNO.Entry.Request'
			method = 'request'
			version = 2
			_sid = $sid
		}
	}
	
	$resp = Invoke-RestMethod @query
	
	if ($resp.data.has_fail) {
		Add-Member -inputObject $resp -notePropertyName 'Request' -notePropertyValue $query
		Throw $resp
	}
	
	return $res.data.result.data.guests
}