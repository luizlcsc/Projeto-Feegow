<%


function logaritmo(data)
    logaritmo = log(replace(data, ",", "")) / log(10)
end function

response.write(10^(0.425*logaritmo(343)+0.725*logaritmo(1)-2.1436))
%>