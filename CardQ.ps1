// Script for Printing Green GC ID Cards
// Files are expected to be in a .XML word document format
// Script pulls configuration from same registry items as application it replaces
// 7/12/2016    abowers      Created

$SpoolDirectory = (Get-ItemProperty "hklm:\SOFTWARE\HTH Worldwide\Document Print Service\WordDocumentPrinter\" -name "SpoolDirectory").SpoolDirectory + "\*"
$PrinterName = (Get-ItemProperty "hklm:\SOFTWARE\HTH Worldwide\Document Print Service\WordDocumentPrinter\" -name "PrinterName").PrinterName 

Get-ChildItem $SpoolDirectory  -Include "*.xml" | 
Foreach-Object {
    $content = Get-Content $_.FullName
    $_.FullName | Out-String

    Try
    {
        $Filename = $_.FullName
        $objWord = New-Object -comobject Word.Application
        $objWord.ActivePrinter = $PrinterName
        $objDocument = $objWord.documents.open($Filename)
        $objDocument.PrintOut()
        $objWord.Quit()
        
        Remove-Item $Filename
    }
    Catch
    {
        $Body = "There was a problem print an ID card `nFile:" + $Filename + "`nPrinter:" + $PrinterName
        $Body | Out-String
        Send-MailMessage -From itadmin@hthworldwide.com -To abowers@hthworldwide.com -Subject "HTH GC ID Card Print Failed" -Body $Body -Attachments $Filename -SmtpServer Vfsmtp1.hthworldwide.com
        Break
    }   
}



