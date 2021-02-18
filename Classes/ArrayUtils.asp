<%
function comparaArray(array1,array2,delimitador)
  array1 = split(array1,delimitador)
  array2 = split(array2,delimitador)
  For i_array1 = 0 to Ubound(array1)
    item_array1 = array1(i_array1)
    For i_array2 = 0 to Ubound(array2)
      
      item_array2 = array2(i_array2)
      if item_array1=item_array2 then
        if possuiItem="" then
          possuiItem=trim(item_array1)
        else
          possuiItem=trim(possuiItem&delimitador&item_array1)
        end if
        'response.write(item_array1&" = "&item_array2&"<br>")
      end if
      
    next
  next
  comparaArray = possuiItem
end function
%>