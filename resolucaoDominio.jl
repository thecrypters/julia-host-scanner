 using Sockets

 for dominio in ARGS
   ip = getaddrinfo(dominio)
   println(dominio," : ",ip)
 end
