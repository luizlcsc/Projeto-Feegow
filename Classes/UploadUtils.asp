<%
function getUploadFolder(licenseId, imageType)
    licenseId = replace(licenseId, "clinic", "")
    basePath = "E://uploads/"

    licenseFolder = basePath& licenseId &"/"

    set filesys=CreateObject("Scripting.FileSystemObject")
    If  Not filesys.FolderExists(licenseFolder) Then
      filesys.CreateFolder (licenseFolder)
    End If

    licenseTypeFolder = licenseFolder&imageType&"/"

    set filesys=CreateObject("Scripting.FileSystemObject")
    If  Not filesys.FolderExists(licenseTypeFolder) Then
      filesys.CreateFolder (licenseTypeFolder)
    End If

    getUploadFolder=licenseTypeFolder

end function
%>