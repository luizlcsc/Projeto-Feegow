<%
'*************************************************************
'*DESCREVER CADA FUNÇÃO E COLOCAR UM EXEMPLO DE USO/APLICAÇÃO*
'*************************************************************

function img404(modelo)
  '**IMAGEM NAO EXISTE
  Select Case modelo
    Case 1 'IMAGEM base64 exibe imagem amigável
    img404Base64  = "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"
    img404        = " onerror='this.src=`data:image/png;base64,"&img404Base64&"`' "

    Case 2 '
    img404        = ""
  End Select
  
end function
'EXEMPLO DE USO
'response.write("<img src='imagem-nao-existe.png' "&img404(1)&">")

function imgSRC(path,licenceID,Folder,File)
  if path="" then path=0 else path=path end if
  Select Case path
    Case 0 'Função Lambida
      imagemSRC = "https://functions.feegow.com/load-image?licenseId="&licenceID&"&folder="&Folder&"&file="&File
  End Select
  
  imgSRC = imagemSRC
end function
'EXEMPLO DE USO
'response.write(imgSRC(0,"5760","Imagens","5760_81788_07052020095048.jpg"))
'response.write("<img src='"&imgSRC(0,"5760","Imagens","5760_81788_07052020095048.jpg")&"' "&img404(1)&">")
%>

