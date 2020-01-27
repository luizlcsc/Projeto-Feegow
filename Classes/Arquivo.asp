<%

function getFileUrl(filename, folder)
    licenseId = replace(session("Banco"), "clinic", "")

    getFileUrl = findFile(filename, folder, licenseId)
end function

function findFile(filename, folder, licenseId)
    relativePath = "uploads/"&licenseId&"/"&folder&"/"&filename

    Dim ServerHost, i
    ServerHost = Array("clinic7", "clinic", "clinic8")
	set fs=Server.CreateObject("Scripting.FileSystemObject")

    Dim xmlhttp



    For Each host In ServerHost
        fileURL = "https://"&host&".feegow.com.br/"&relativePath

        Set xmlhttp = Server.CreateObject("MSXML2.ServerXMLHTTP")

        xmlhttp.open "HEAD", fileURL, False
        xmlhttp.send

        Select Case Cint(xmlhttp.status)
            Case 200, 202, 302
                Set xmlhttp = Nothing
                findFile=fileURL
                Exit For
            Case Else
                Set xmlhttp = Nothing
        End Select

    Next
end function

function getFileUrlWithCustomDB(filename, folder, licenseId)
    getFileUrlWithCustomDB = findFile(filename, folder, licenseId)
end function


%>