<!--#include file="connect.asp"-->
<!--#include file="JSON.asp"-->
<%
Set JSONObject = jsObject()

For Each Key In Session.Contents
    If Not IsObject(Session.Contents(Key)) Then 'skip the objects cannot be serialized
        JSONObject(Key) = Session.Contents(Key)
    End If
Next


JSONObject.Flush
%>