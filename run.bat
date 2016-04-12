rmdir /s/q .\simulator\win32\res
rmdir /s/q .\simulator\win32\src
xcopy .\res .\simulator\win32\res /s /e /i
xcopy .\src .\simulator\win32\src /s /e /i
.\simulator\win32\code04111.exe