setwd("/Users/aldo/Google Drive/CCB/Simulador Dx")
rm(list = ls())
require(data.table)
#preg=data.table(read.csv2("Reporte_preguntas_respuestas febrero 03_2016.txt",stringsAsFactors = F))
#save(preg,file="backUps/pregResp.RData")
load("backUps/pregResp.RData")
preg[,FechaCreacion:=
       as.Date(sapply(strsplit(FechaCreacion," "),function(x) x[1]),"%m/%d/%y")]
#filtro la base para lo que necesito (solo los ejes con peso)
preg=preg[grepl("fortalecimiento",diagnostico,ignore.case = T)&version==5
          &!grepl("innova|inter|general",Eje_tematico,ignore.case = T)]

#ahora en un segundo saco las variables que no necesito 
#Eje_tematico,Orden_pregunta,Seleccion_multiple,Orden_respuesta
preg[,c("Orden_pregunta", "Seleccion_multiple", "Orden_respuesta"):=NULL]

#leamos la matriz con las preguntas, las respuestas y los pesos
require(openxlsx)
pesos=data.table(read.xlsx("pesosPreguntasyRespuestas.xlsx",startRow = 2))
pesos[,Eje.Pregunta.Respuesta:=gsub("[[:space:]]$","",Eje.Pregunta.Respuesta)]

#un data.table donde voy a ir guardando las combinaciones y poniendo el peso total
#multimplicando todos los factores que lo afecten
pesosFinales=data.table(ejeP=character(0),preguntaP=character(0),respuestaP=character(0),
                        puntajeP=character(0))

#I must reshape 'pesos' so that the order of the lines matter and gives the 
#information about what kind of row we are using in regards of: eje, pregunta and
#respuesta
#
#The way to do this is explained in this stackoverflow link:	
# goo.gl/hRPwYx

#it's not that simple (this people in SO are just genius), they use a cummulative sum
#on the difference of a match type. The plan is getting the numerical order of the category
#(in hierarchycal order) so that when we get a difference in hierarchy of 0 or less we get
#a new row. Then we use a cummulative sum of this condition to number the rows. Finally we
#add na.locf to carry on values from the past

#before all that I need to get the umbrales out of the Dt
Umbrales=pesos[Tipo=="Umbral"]
pesos=pesos[!Tipo=="Umbral"]
setnames(pesos,"Peso.de.prueba","p")
#now I really got what I wanted ha!
require(zoo)
pesosFinales=pesos
pesosFinales[,rowType:=match(Tipo,c("Eje","Pregunta","Respuesta"))][
             ,newRow:=cumsum(diff(c(0,rowType))<=0)]
pesosFinales=na.locf(dcast(pesosFinales,newRow~Tipo,value.var = c("Eje.Pregunta.Respuesta","p")))
