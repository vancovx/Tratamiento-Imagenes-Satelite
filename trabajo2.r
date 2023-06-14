
#instalamos la biblioteca sen2r que proporciona herramientas para acceder y 
  # procesar imágenes satelitales 
install.packages("sen2r")
library(sen2r())

#abrimos la interfaz gráfica de usuario (GUI) que nos permite interactuar con
  # las imágenes y realizar diferentes operaciones
s2_gui()

#iniciamos sesion en el portal SciHub, que es una plataforma de datos satelitales
write_scihub_login(username = "estrelladomsan", password = "SEN2Restrella04")


#instalamos los paquetes necesarios
install.packages(c("leafpm", "mapedit",
                   "shinyFiles", "shinydashboard", "shinyjs",
                   "shinyWidgets"))

library(leafpm)
library(mapedit)
library(shinyFiles)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)

#definimos una ventana temporal para buscar dentro de un rango de fechas con la 
  # función as.Date y definiendo un vector de fechas
time_window <- as.Date(c("2020-05-01","2020-05-05"))

#definimos la escena en la que vamos a trabajar (el tile o mosaico)
  # en este caso trabajamos con 30TXM que es de Zaragoza
tile = "30TXM"

#porcentaje de nubes máximo que aparecerá en nuestra imagen
max_cloud = 20

#comprobamos que existen imagenes con esas características usando la función s2_list()
list_safe <- s2_list(tile = tile, time_interval = time_window, max_cloud = max_cloud)

#accedemos a los metadatos de las imágenes utilizando safe_getMetadata(),
  # que muestra información como la fecha de captura y los nombres de las imágenes
safe_getMetadata(list_safe, "sensing_datetime")
safe_getMetadata(list_safe, "nameinfo")

#creamos un directorio para descargar ahí las imágenes
path <- "C:/Users/estre/OneDrive/Escritorio/UNI/2 cuatri/Mates ii/R/Trabajo/"

#creamos un directorio en el que se guardarán las imágenes descargadas
path_save <- paste0(path,"prueba/")
dir.create(path_save)

#descargamos las imágenes que cumplen con los criterios especificados utilizando
  # se_download() y proporcionando la lista de imágenes obtenida anteiormente
  # y el directorio de destino
s2_download(list_safe, outdir = path_save)

#COMPROBAMOS DRECTORIOS
#creamos un directorio que contiene todas las carpetas
dirs <- list.dirs(path = path_save)

#aplicamos un filtro para que nos seleccione solamente las carpetas que contienen
  # "IMG_DATA", que es la carpeta que contiene todas las imágenes
dirs <- dirs[grep("IMG_DATA", dirs)]

#creamos una variable que liste todos los archivos de la carpeta
v_files <- list.files(dirs[1], full.names = TRUE, recursive = TRUE)


#ACCEDER A OBJETOS
#accedemos al objeto 2 (empieza desde la posición 1)
print(v_files[2])

#FILTRACIONES POR PATRON DE TEXTO
#filtramos los archivos para que nos selecciones solamente los que terminan por 
  # 20m.jp2 (es decir, las imágenes a 20 metros)
v_files <- list.files(path = path_save, pattern = "20m.jp2", full.names = TRUE, recursive = TRUE)

#LIBRERIA RASTER (análisis de imágenes)
#instalamos la libreria
library(sp) #esta es requerida para usar raster
library(raster)

#COLOREAR IMAGEN EN COLOR VERDADERO
#elegimos el objeto 12
plotRGB(stack(v_files[12]), red = 1, green = 2, blue = 3)

#cargamos la banda 2 (azul) desde el archivo
b02 <- raster(v_files[2])
plot(b02)

#una vez tenemos cargada la banda:
#EXPLORAMOS LA INFORMACIÓN DE LA IMAGEN

#accedemos a la proyeccion: obtencion de datos:
crs(b02) #CRS: Coordenadas de la imagen
res(b02) #Resolución X - y
xres(b02) #Resolución X
yres(b02) #Resolución Y
ncell(b02) #número de celdas
dim(b02) #dimensiones
extent(b02) #Estensión x-y

#guardamos los valores del raster en un objeto
b02_hist <- getValues(b02)
#mostramos las primeras filas de los valores de píxeles de la banda 2. 
  # Esto permite tener una idea de los rangos y distribución de los valores
head(b02_hist)

#generamos un histograma


##############ESTO NO SE SI HACE ALGO##################

#par(mar=c(4,4,4,4))

#######################################################

hist(b02_hist, breaks=5000, xlim=c(0,3000)) #definimos los margenes e intervalos

#filtramos archivos por nombre
#definimos unas cadenas de texto con las que filtraremos los datos
patterns <- c("B02", "B03", "B04", "B05", "B06", "B07", "B11", "B12", "B8A")
#Seleccionamos los archivos de v_files que contienen la cadena anterior
brick_files <- unique(grep(paste(patterns, collapse = "|"), v_files, value = TRUE))

#creamos con la función stack un archivo multivanda
sen2 <- stack(brick_files)
plot(sen2)

#modificamos los nombres de las bandas
names(sen2) <- c('blue', 'green', 'red', 'RE1', 'RE2', 'RE3', 'SWIR1', 'SWIR2', 'NIR')
plot(sen2)

#Composiciones de color
plotRGB(sen2, r="red", g="green", b="blue", axes = TRUE, stretch = "lin", main = "True Color")
plotRGB(sen2, r="NIR", g="red", b="green", axes = TRUE, stretch = "lin", main = "False Color Infrarojo")
plotRGB(sen2, r="SWIR1", g="NIR", b="red", axes = TRUE, stretch = "lin", main = "SWIR")
plotRGB(sen2, r="NIR", g="RE3", b="blue", axes = TRUE, stretch = "lin", main = "Vegetación")
plotRGB(sen2, r="SWIR2", g="SWIR1", b="blue", axes = TRUE, stretch = "lin", main = "Masas de Agua")


#Cálculo de índices
#NDVI: contrasta la diferencia entre la banda del rojo y del infrarrojo cercano; 
  # puede ofrecer debilidades a la hora de enmascarar superficies relativamente distintas
  #Los colores altos corresponden a zonas de vegetación.
NDVI <- (sen2$NIR - sen2$red) / (sen2$NIR + sen2$red)
plot(NDVI)

#NDWI: Se utiliza para detectar masas de agua
NDWI <- (sen2$green - sen2$NIR) / (sen2$green + sen2$NIR)
plot(NDWI)

#NBR: se utiliza para detectar áreas afectadas por incendios
NBR <- (sen2$NIR - sen2$SWIR1) / (sen2$NIR + sen2$SWIR1)
plot(NBR)

#filtros para los indices:
#detectar zonas con un NDWI > 0.3
NDWI_filt <- NDWI > 0.3
plot(NDWI_filt)

