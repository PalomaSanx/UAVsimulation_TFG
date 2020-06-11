# TRABAJO FIN DE GRADO

_Gestión dinámica de colisiones en entornos con múltiples drones_

![Dron](https://github.com/PalomaSanx/UAVsimulation_TFG/blob/master/imgReadme/dron.png)

## Introducción 🚀

_En un futuro no muy lejano se prevee que los drones sean un elemento habitual dentro del espacio aéreo,
especialmente en entornos urbanos (aunque no exclusivamente). Uno de los múltiples servicios que
prestarán estos aparatos será la entrega de paquetería. De hecho, empresas del sector como Amazon o
DHL ya tienen propuestas en este campo._

_En este TFG nos planteamos pues un escenario en el que múltiples drones autónomos sobrevuelan un área
determinada, en base a unas rutas o planes de vuelo preestablecidos. En este escenario, y al igual que
sucede en el entorno aéreo "tradicional", deberán desarrollarse mecanismos para detectar y resolver en
tiempo real cualquier colisión entre los drones en vuelo, entendiendo por colisión una situación en la que
dos (o más) de ellos se encuentran a una distancia inferior a un umbrar de seguridad._


### Algoritmo "Bounding Box Collision Avoidance" (BBCA)

_En este trabajo se propone un algoritmo como mecanismo para la detección y evitación de colisiones en escenarios con múltiples drones. El algoritmo propuesto (“Bounding Box Collision Avoidance”) está basado en técnicas geométricas, buscando mejorar, por su sencillez, otros métodos presentes en la literatura.
Este algoritmo ha sido implementado mediante la herramienta MATLAB, para escenarios dinámicos, donde los UAV sobrevuelan el espacio aéreo de forma autónoma y deben tomar decisiones en tiempo real. La solución funciona de forma descentralizada, ya que se consideran escenarios congestionados (con cientos de drones)._

_Para la visualización y obtención de datos, se ha desarrollado un analizador a través de MATLAB, que permita ejecutar el algoritmo y poder graficar cada paso de este a la vez que visualizamos el vuelo de los diferentes UAV involucrados. Los datos obtenidos, para simulaciones con dos o múltiples UAV, permiten el estudio y análisis del comportamiento del algoritmo. ._  

![Dron](https://github.com/PalomaSanx/UAVsimulation_TFG/blob/master/imgReadme/simulacion.jpg)

## Instalación y ejecución ⚙️

### Simulador 3D

_Descargar el repositorio y abrir el mismo desde Matlab._

_Abrir aplicación app Designer de Matlab y ejecutar simulación._

### Analizador de algoritmo

_Descargar el repositorio y abrir el mismo desde Matlab._

_Abrir script del analizador en Matlab y ejecutar._

![Video_BBCA](https://github.com/PalomaSanx/UAVsimulation_TFG/blob/master/imgReadme/BBCA.gif)

## Herramientas empleadas 🛠️

* [Matlab](https://es.mathworks.com/) - Matlab
* [Simulink](https://es.mathworks.com/products/simulink.html) - Simulink

## Wiki 📖

A través del siguiente enlace puedes acceder a más información, como la documentación principal de este proyecto. [Wiki](https://github.com/PalomaSanx/UAVsimulation_TFG/tree/master/wiki)

## Versionado 📌

Usamos [SemVer](http://semver.org/) para el versionado. Para todas las versiones disponibles, mira los [tags en este repositorio](https://github.com/PalomaSanx/UAVsimulation_TFG.git/tags).

## Autores ✒️

* **Paloma Sánchez** - *Autor* - [palomasanx](https://github.com/PalomaSanx)
* **Rafael Casado González** - *Director* - 
* **Aurelio Bermúdez Martín** - *Director* - 

## Licencia 📄

Este proyecto está bajo la Licencia (Tu Licencia) - mira el archivo [LICENSE.md](LICENSE.md) para detalles

