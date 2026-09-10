* Encoding: windows-1252.
*Clase 5: Distribución del ingreso

*APROXIMACION DESCRIPTIVA BÁSICA

*Medidas de tendencia central

weight by pondih.

FREQUENCIES VARIABLES=IPCF
  /STATISTICS=STDDEV MEAN MEDIAN MODE
  /ORDER=ANALYSIS.

*Medidas de posición

FREQUENCIES VARIABLES=IPCF
  /FORMAT=NOTABLE
  /NTILES=10
  /ORDER=ANALYSIS.

*Comparando la distribución según nivel educativo del jefe: coeficiente de variabilidad

USE ALL.
COMPUTE filter_$=(h_educajefe=1).
FILTER BY filter_$.
EXECUTE.

weight by pondih.

FREQUENCIES VARIABLES=IPCF
    /FORMAT=NOTABLE
  /STATISTICS=STDDEV MEAN MEDIAN MODE
  /ORDER=ANALYSIS.

USE ALL.
COMPUTE filter_$=(h_educajefe=4).
FILTER BY filter_$.
EXECUTE.

weight by pondih.

FREQUENCIES VARIABLES=IPCF
    /FORMAT=NOTABLE
  /STATISTICS=STDDEV MEAN MEDIAN MODE
  /ORDER=ANALYSIS.

*Brechas de ingreso

filter off.
weight by pondih.

RANK VARIABLES=IPCF (A)
  /NTILES(10)
  /PRINT=YES
  /TIES=MEAN.

* Tablas personalizadas.
CTABLES
  /VLABELS VARIABLES=NIPCF IPCF DISPLAY=BOTH
  /TABLE NIPCF [C] > IPCF [S][MEAN, COUNT F40.0, SUM]
  /CATEGORIES VARIABLES=NIPCF ORDER=A KEY=VALUE EMPTY=EXCLUDE TOTAL=YES POSITION=AFTER
  /CRITERIA CILEVEL=95.

*APROXIMACIÓN VISUAL

*Primero, ver qué pasa si no tenemos ningún filtro

* Generador de gráficos.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=IPCF MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: IPCF=col(source(s), name("IPCF"))
  GUIDE: axis(dim(1), label("MONTO DEL INGRESO PER CÁPITA FAMILIAR."))
  GUIDE: axis(dim(2), label("Porcentaje de frecuencia"))
  GUIDE: text.title(label("Polígono de frecuencias de MONTO DEL INGRESO PER CÁPITA FAMILIAR."))
  ELEMENT: area(position(smooth.spline(summary.percent.count(bin.rect(IPCF), 
    base.all(acrossPanels())))), missing.wings())
END GPL.

*Ahora, excluimos a los outliers

FREQUENCIES VARIABLES=IPCF
  /FORMAT=NOTABLE
  /PERCENTILES=1.0 99.0 
  /STATISTICS=STDDEV MINIMUM MAXIMUM
  /ORDER=ANALYSIS.

USE ALL.
COMPUTE filter_$=(ipcf>16000 & ipcf<848000).
FILTER BY filter_$.
EXECUTE.

* Generador de gráficos.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=IPCF MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: IPCF=col(source(s), name("IPCF"))
  GUIDE: axis(dim(1), label("MONTO DEL INGRESO PER CÁPITA FAMILIAR."))
  GUIDE: axis(dim(2), label("Porcentaje de frecuencia"))
  GUIDE: text.title(label("Polígono de frecuencias de MONTO DEL INGRESO PER CÁPITA FAMILIAR."))
  ELEMENT: area(position(smooth.spline(summary.percent.count(bin.rect(IPCF, binStart(0), 
    binWidth(20000)), base.all(acrossPanels())))), missing.wings())
END GPL.

USE ALL.
COMPUTE filter_$=((ipcf>16000 & ipcf<848000) & h_educajefe=1).
FILTER BY filter_$.
EXECUTE.


* Generador de gráficos.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=IPCF MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: IPCF=col(source(s), name("IPCF"))
  GUIDE: axis(dim(1), label("MONTO DEL INGRESO PER CÁPITA FAMILIAR."))
  GUIDE: axis(dim(2), label("Porcentaje de frecuencia"))
  GUIDE: text.title(label("Polígono de frecuencias de MONTO DEL INGRESO PER CÁPITA FAMILIAR."))
  ELEMENT: area(position(smooth.spline(summary.percent.count(bin.rect(IPCF, binStart(0), 
    binWidth(20000)), base.all(acrossPanels())))), missing.wings())
END GPL.


USE ALL.
COMPUTE filter_$=((ipcf>16000 & ipcf<848000) & h_educajefe=4).
FILTER BY filter_$.
EXECUTE.


* Generador de gráficos.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=IPCF MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: IPCF=col(source(s), name("IPCF"))
  GUIDE: axis(dim(1), label("MONTO DEL INGRESO PER CÁPITA FAMILIAR."))
  GUIDE: axis(dim(2), label("Porcentaje de frecuencia"))
  GUIDE: text.title(label("Polígono de frecuencias de MONTO DEL INGRESO PER CÁPITA FAMILIAR."))
  ELEMENT: area(position(smooth.spline(summary.percent.count(bin.rect(IPCF, binStart(0), 
    binWidth(20000)), base.all(acrossPanels())))), missing.wings())
END GPL.

*INDICADORES DE CONCENTRACIÓN: EL COEFICIENTE DE GINI

*Lo vamos a calcular con SPSS a partir de datos agrupados. Para una aproximación más sencilla con microdatos, se puede utilizar el módulo DASP de Stata que se comenta en el Campus.

compute ALEA= RV.NORMAL(0.1,0.1) .
execute.

compute IPCF_ALEA= IPCF + ALEA.
execute.

RANK VARIABLES=IPCF_ALEA (A)
  /NTILES(99)
  /PRINT=YES
  /TIES=MEAN.

weight by PONDIH.
filter off.

* Tablas personalizadas.
CTABLES
  /VLABELS VARIABLES=NIPCF_AL IPCF DISPLAY=BOTH
  /TABLE NIPCF_AL > IPCF [S][MEAN, COUNT F40.0, SUM]
  /CATEGORIES VARIABLES=NTI001 ORDER=A KEY=VALUE EMPTY=EXCLUDE TOTAL=YES POSITION=AFTER
  /CRITERIA CILEVEL=95.
