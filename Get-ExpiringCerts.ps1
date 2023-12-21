$Certs = Get-ChildItem cert:\ -Recurse | Where-Object {$_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2]} | Select-Object -Unique -Property NotAfter, FriendlyName, Thumbprint, Subject
$Now = Get-Date

$Count1 = Read-Host "Return all local certificates that have expired in the last how many days? (Please type a number)"

if ($Expired = $Certs | Where-Object {$_.NotAfter -le $Now -And $_.NotAfter -ge $Now.AddDays(-$Count1)} | Sort-Object NotAfter | Format-List) {$Expired}
else {"`nNo certificates on this machine have expired in the last $Count1 days.`n"}

$Count2 = Read-Host "Return all local certificates that are expiring in the next how many days? (Please type a number)"

if ($Expiring = $Certs | Where-Object {$_.NotAfter -le $Now.AddDays($Count2) -And $_.NotAfter -ge $Now} | Sort-Object NotAfter | Format-List) {$Expiring}
else {"`nNo certificates on this machine are expiring in the next $Count2 days.`n"}

# Offer to restart the script https://github.com/JedHarb/Restart-Powershell-Script/blob/main/Restart-PSScript.ps1
if ((Read-Host "`nEnter Y to restart this script") -eq "Y") {
	# Reset most of the local automatic variables that started with powershell back to their initial values (some are read-only).
	try {
		((& powershell "Get-Variable") | Select-Object -Skip 3 | ConvertFrom-String -PropertyNames Name, Value).ForEach({
			Set-Variable -Name $_.Name -Value $_.Value -ErrorAction SilentlyContinue
		})
	}
	catch {}

	# Remove all additional variables created in this session.
	try {
		Remove-Variable -Name (Compare-Object (Get-Variable) ((& powershell "Get-Variable") | 
  		ConvertFrom-String -PropertyNames Name) -Property Name | 
    		Where-Object SideIndicator -eq "<=").Name -ErrorAction SilentlyContinue
	}
	catch {}

	# Reset the last few stragglers
	# $Error.Clear() # Every once in awhile, this throws a "Method invocation failed because [System.String] does not contain a method named 'Clear'." and I haven't been able to pin down why.
	$$, $StackTrace = ""

	# The automatic variable $^ can't be manually removed, reset, or changed in any way (at least in all of my testing).
	# It will become equal to the literal text 'try' at this point, and change with each command run from here (as usual).
 	
	.$PSCommandPath # Start the script from the beginning.
}
