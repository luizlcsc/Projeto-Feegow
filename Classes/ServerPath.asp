<%
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
%>