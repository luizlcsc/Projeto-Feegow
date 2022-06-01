<!--#include file="Environment.asp"--><%
function appUrl(includeVersionFolder)
    set shellExec = createobject("WScript.Shell")
    Set objSystemVariables = shellExec.Environment("SYSTEM")
    getAppEnv = objSystemVariables("FC_APP_ENV")

    app_url_var = Request.ServerVariables("SERVER_NAME")
    versionFolder = "/v7-master"
    httpProtocol = "https"

    if app_url_var="::1" then
        app_url_var="localhost"
        versionFolder="/feegowclinic-v7"
        httpProtocol = "http"
    end if

    app_url_var=httpProtocol&"://"&app_url_var

    if includeVersionFolder then
        app_url_var=app_url_var&versionFolder
    end if

    appUrl=app_url_var
end function

function getCurrentVersion()
    PathInfo = Request.ServerVariables("PATH_INFO")

    currentVersionFolder = replace(replace(PathInfo,"index.asp",""),"/","")
    if inStr(PathInfo,".asp") then
        splitVar = split(PathInfo, "/")
        currentVersionFolder = splitVar(1)
    end if
    AppEnv = getEnv("FC_APP_ENV", "local")
        
    if AppEnv<>"production" then
        if ModoFranquia then
            currentVersionFolder="v7.6"
        else
            currentVersionFolder="main"
        end if
    end if
    
    getCurrentVersion = currentVersionFolder
end function
%>