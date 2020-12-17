<%
set shellExec = createobject("WScript.Shell")
Set objSystemVariables = shellExec.Environment("SYSTEM")

function getEnv(EnvVariable, DefaultValue)
    envValue = objSystemVariables(EnvVariable)
    if envValue&""="" then
        getEnv = DefaultValue
    else
        getEnv = envValue
    end if
end function
%>
