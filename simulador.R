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
