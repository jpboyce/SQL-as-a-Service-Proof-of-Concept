# This will create a new Source Type in the Application Event Log to allow other scripts to log against vRealize Events in Windows

Write-Output "Creating Log Source"
New-EventLog -LogName Application -Source $Log_Name -ErrorAction SilentlyContinue
Write-Output "Script Finished"

# END
