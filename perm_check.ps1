$file=$env:computername+'-reg-perm.txt'
echo $file

echo 3.4.2.1 | Out-file $file -append
echo '------' | Out-file $file -append
get-acl HKLM:\SYSTEM\CURRENTCONTROLSET\CONTROL\SECUREPIPESERVERS\WINREG | Format-list | Out-file $file -append

echo 3.4.2.3 | Out-file $file -append
echo '------' | Out-file $file -append
get-acl HKLM:\SOFTWARE\MICROSOFT\OLE | Format-list | Out-file $file -append

echo 3.4.2.4 | Out-file $file -append
echo '------' | Out-file $file -append
get-acl HKLM:\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\RUN | Format-list | Out-file $file -append
get-acl HKLM:\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\RUNONCE | Format-list | Out-file $file -append
get-acl HKLM:\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\UNINSTALL | Format-list | Out-file $file -append

echo 3.4.6.9 | Out-file $file -append
echo '------' | Out-file $file -append
get-acl HKLM:\SOFTWARE\MICROSOFT\SYSTEMCERTIFICATES\AUTHROOT | Format-list | Out-file $file -append