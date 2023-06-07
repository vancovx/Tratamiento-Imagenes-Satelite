
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



#comprobar lo que hemos hecho

#creamos un directorio que contiene todas las carpetas
dirs <- list.dirs(path = path_save)

#aplicamos un filtro para que nos seleccione solamente las carpetas que contienen "IMG_DATA", que es la carpeta que contiene todas las imagenes
dirs <- dirs[grep("IMG_DATA", dirs)]

#creamos una variable que liste todos los archivos de la carpeta
v_files <- list.files(dirs[1], full.names = TRUE, recursive = TRUE)

#accedemos al objeto 2 (empieza desde la posicion 1)
print(v_files[2])

#filtramos los archivos para que nos selecciones solamente los que terminan por 20m.jp2
v_files <- list.files(path = path_save, pattern = "20m.jp2", full.names = TRUE, recursive = TRUE)




