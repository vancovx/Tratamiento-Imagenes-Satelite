
#de aqui podremos cargar imagenes
s2_gui()
y
library(sen2r())
sen2r()

#iniciamos sesion en scihub
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

#definimos una ventana temporal para buscar entre esas dos fechas
time_window <- as.Date(c("2020-05-01","2020-05-05"))

#definimos la escena en la que vamos a trabajar (El tile); 30TXM es de Zaragoza
tile = "30TXM"

#porcentaje de nubes maximo que aparecera en nuestra imagen
max_cloud = 20

#comprobamos que existen imagenes con esas caracteristicas
list_safe <- s2_list(tile = tile, time_interval = time_window, max_cloud = max_cloud)

#esto comprueba los metadatos que nos devuelve la lista anterior
safe_getMetadata(list_safe, "sensing_datetime")
safe_getMetadata(list_safe, "nameinfo")

#creamos un directorio para descargar ahi la imagen
path <- "C:/Users/estre/OneDrive/Escritorio/UNI/Mates ii/R/Trabajo/"

#le añadimos una carpeta nueva a la ruta anterior
path_save <- paste0(path,"prueba/")
dir.create(path_save)

#guardamos la imagen en la ruta creada
s2_download(list_safe, outdir = path_save)



#COMPROBAMOS DRECTORIOS
#creamos un directorio que contiene todas las carpetas
dirs <- list.dirs(path = path_save)

#aplicamos un filtro para que nos seleccione solamente las carpetas que contienen "IMG_DATA", que es la carpeta que contiene todas las imagenes
dirs <- dirs[grep("IMG_DATA", dirs)]

#creamos una variable que liste todos los archivos de la carpeta
v_files <- list.files(dirs[1], full.names = TRUE, recursive = TRUE)


#ACCEDER A OBJETOS
#accedemos al objeto 2 (empieza desde la posicion 1)
print(v_files[2])

#FILTRACIONES POR PATRON DE TEXTO
#filtramos los archivos para que nos selecciones solamente los que terminan por 20m.jp2 (es decir, las imagenes a 20 metros)
v_files <- list.files(path = path_save, pattern = "20m.jp2", full.names = TRUE, recursive = TRUE)




#LIBRERIA RASTER
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
crs(b02) #CRS
res(b02) #Resolución X - y
xres(b02) #Resolución X
yres(b02) #Resolución Y
ncell(b02) #número de celdas
dim(b02) #dimensiones
extent(b02) #Estensión x-y

#guardamos los valores del raster en un objeto
b02_hist <- getValues(b02)
head(b02_hist)

#generamos un histograma
par(mar=c(4,4,4,4))
hist(b02_hist, breaks=5000, xlim=c(0,3000)) #definimos los margenes e intervalos


#RECORTAR IMAGEN
#obtenemos las coordenadas limites con la funcion extent
xy_ext <- extent(xmin(b02), xmax(b02), ymin(b02), ymax(b02))

#obtenemos un clip del cuadrado central de la imagen
xmax <- xmax(b02) - ((abs(xmax(b02) - xmin(b02))/2)/2)
xmin <- xmin(b02) - ((abs(xmax(b02) - xmin(b02))/2)/2)
ymax <- ymax(b02) - ((abs(xmax(b02) - xmin(b02))/2)/2)
ymin <- ymin(b02) - ((abs(xmax(b02) - xmin(b02))/2)/2)

xy_ext <- extent(xmin,xmax,ymin,ymax)
plot(b02)
plot(xy_ext, add=TRUE) #cuadro delimitador


#MINUTO 25:40