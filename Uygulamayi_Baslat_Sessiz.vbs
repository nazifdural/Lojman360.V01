' ==========================================================================
'  AND360 LOJMAN YONETIM SISTEMI - SESSIZ BASLATMA
'
'  Uygulamayi konsol penceresi ACMADAN baslatir.
'
'  NEDEN VBSCRIPT
'  Bat dosyasi calistiginda Windows her zaman bir konsol penceresi acar;
'  "@echo off" yalnizca komutlari gizler, pencereyi degil. WScript.Shell
'  ise pencereyi hic olusturmadan calistirabiliyor (ucuncu parametre 0).
'
'  KAYIT DOSYASI
'  Pencere gizlenince hata mesajlari da gorunmez olur. Bu yuzden butun
'  cikti gunluk\sunucu.log dosyasina yaziliyor. Uygulama acilmazsa
'  bakilacak ilk yer orasi.
'
'  DURDURMA
'  Ctrl+C basacak pencere kalmadigi icin durdurmak "Uygulamayi_Durdur.bat"
'  ile yapilir.
' ==========================================================================

Option Explicit

Dim kabuk, dosya, klasor, gunlukKlasoru, komut, venv

Set kabuk = CreateObject("WScript.Shell")
Set dosya = CreateObject("Scripting.FileSystemObject")

' Bu betigin bulundugu klasor
klasor = dosya.GetParentFolderName(WScript.ScriptFullName)
kabuk.CurrentDirectory = klasor

venv = klasor & "\.venv\Scripts\python.exe"

If Not dosya.FileExists(venv) Then
    MsgBox "Kurulum bulunamadi." & vbCrLf & vbCrLf & _
           "Once 01_Kurulum.bat dosyasini calistirin.", _
           vbCritical, "AND360"
    WScript.Quit 1
End If

If Not dosya.FileExists(klasor & "\.env") Then
    MsgBox ".env ayar dosyasi bulunamadi." & vbCrLf & vbCrLf & _
           "Once 01_Kurulum.bat dosyasini calistirin.", _
           vbCritical, "AND360"
    WScript.Quit 1
End If

' Gunluk klasoru yoksa olustur
gunlukKlasoru = klasor & "\gunluk"
If Not dosya.FolderExists(gunlukKlasoru) Then
    dosya.CreateFolder gunlukKlasoru
End If

' Cikti ve hata ayni dosyaya. cmd /c gerekiyor cunku yonlendirme (>)
' kabugun isi; python'a dogrudan verilemez.
komut = "cmd /c """"" & venv & """ -m scripts.run_server > """ & _
        gunlukKlasoru & "\sunucu.log"" 2>&1"""

' Ucuncu parametre 0 = pencere hic gorunmez.
' Dorduncu parametre False = beklemeden don.
kabuk.Run komut, 0, False

Set kabuk = Nothing
Set dosya = Nothing
