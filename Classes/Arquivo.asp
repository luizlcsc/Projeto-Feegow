<!--#include file="../connect.asp"-->
<%

function getFileUrl(filename, folder)
    licenseId = replace(session("Banco"), "clinic", "")

    getFileUrl = findFile(filename, folder, licenseId)
end function

function findFile(filename, folder, licenseId)

   img =  arqEx(filenme, folder)

end function

function getFileUrlWithCustomDB(filename, folder, licenseId)
    getFileUrlWithCustomDB = findFile(filename, folder, licenseId)
end function


%>