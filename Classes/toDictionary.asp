<!--#include file="../functions.asp"-->
<%
function toDictionary(value)
    value = treatStr(value)
    Dim d
    Set d=Server.CreateObject("Scripting.Dictionary")
    tipo = ""
    if InStr(LCase(value), "insert") then
        colunas = InsertCols(value)
        valores = InsertVals(value)
        tipo = "insert"
        tabelaIns = discoverTableName(value,tipo)
        discoverLastIDSQL= "SELECT LAST_INSERT_ID() as id"
        set lastID = db.execute(discoverLastIDSQL)
        tabelaIns2 = UCase(Left(tabelaIns, 1)) & Mid(tabelaIns, 2,len(tabelaIns)-2)
        d.add  tabelaIns2&"ID", lastID("id")&""
    end if
    if InStr(LCase(value), "update") then
        colunas = UpdateCols(value)
        valores = UpdateVals(value)
        tipo = "update"
    end if
    for i=0 to ubound(colunas)-1
        d.Add colunas(i), valores(i)
    next
   set toDictionary = d
end function
function treatStr(value)
    value = replace(value,";","")
    value = replace(value,"SET","set")
    value = replace(value,"WHERE","where")
    value = replace(value,"UPDATE","update")
    value = replace(value,"INTO","into")
    value = replace(value,"'","")
    treatStr = value
end function
function discoverTableName(value,tipo)
    if tipo = "insert" then
        splTable1 = split(value,"(")
        splTable2 = split(splTable1(0),"into")
        ptable = splTable2(1)
    else
        splTable1 = split(value,"set")
        splTable2 = replace(splTable1(0),"update","")
        ptable = splTable2
    end if
    tableName = trim(ptable)
    discoverTableName = tableName
end function
function InsertCols(value)
    colSp1 = Split(trim(value),"(")
    colSp2 = Split(colSp1(1),")")
    colunas = split(colSp2(0),",")
    InsertCols = colunas
end function
function InsertVals(value)
    valSp0 = Split(trim(value),"(")
    valSp1 = Split(valSp0(2),"(")
    valSp2 = Split(valSp1(0),")")
    valores = split(valSp2(0),",")
    InsertVals = valores
end function
function UpdateCols(value)
    colSp1 = Split(trim(value),"set")
    colSp2 = Split(colSp1(1),"where")
    colSp3 = split(colSp2(0),",")
    colunas = ""
    For i=0 To  ubound(colSp3)-1
        If i>0 Then
            colunas = colunas&","
        end if
        splcol = split(colSp3(i),"=")
        colunas = colunas&splcol(0)
    Next
    colunas = split(colunas,",")
    UpdateCols = colunas
end function
function UpdateVals(value)
    valSp1 = Split(trim(value),"set")
    valSp2 = Split(valSp1(1),"where")
    valSp3 = split(valSp2(0),",")
    valores = ""
    For i=0 To  ubound(valSp3)-1
        If i>0 Then
            valores = valores&","
        end if
        splval = split(valSp3(i),"=")
        valores = valores&splval(0)
    Next
    valores = split(valores,",")
    UpdateVals = valores
end function
%>