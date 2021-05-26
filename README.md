## Loosy
Sintetizador en realidad mixta que constituye el TFG de Juan Riera Gomez. En este github se halla el código ChucK del módulo del sintetizador y los blueprints de Unreal Engine del módulo controlador

# Distribución de carpetas
Como se ha mencionado, el proyecto se compone de dos módulos, así que están separados aquí por carpetas. En una está el módulo de síntesis LoosySynth desarrollado en formato ChucK. En otro está el módulo controlador, diseñado para las gafas Hololens 2 o en un entorno de emulación, y desarrollado en Unreal Egine.

# Ficheros de configuración
Se incluyen también los ficheros de configuración. El fichero de configuración del módulo de síntesis se debe almacenar en la misma carpeta que los módulos de código. En el caso del controlador, en la carpeta Content del proyecto que se cree. 

# LoosySynth: Instrucciones de ejecución y herramientas necesarias.
Los ficheros de chuck se pueden ejecutar a través de la herramienta de desarrollo miniAudicle. También se pueden ejecutar con le comando:

  chuck main.ck
 
Si se tiene la máquina virtual de ChucK instalada. Todo se puede encontrar aquí: https://chuck.cs.princeton.edu/
Los ficheros son texto, así que incluso sin la herramienta asociada cualquiera puede leer el código.


# LoosyController: Instrucciones de ejecución y herramientas necesarias.
  
El módulo de controlador se ejecuta en Unreal Engine, así que se debe crear un proyecto e importar los UAssets, que son las clases necesarias. Estos ficheros no son código propiamente dicho y por tanto no son legibles por un humano sin Unreal Engine. Para descargar Unreal Engine:

https://www.unrealengine.com/en-US/download

Para configurar un proyecto de desarrollo en Hololens 2 ver los apéndices del trabajo, o:

https://docs.google.com/document/d/1YONkNpbu_9F4smR9U928tUrF-tmd6qcLXNfGjQ09_6w/edit?usp=sharing

Además de las clases, se incluyen también el resto de ficheros del proyecto: el nivel, Pawn por defecto, y el fichero de configuración de sesión.

# Últimas anotaciones

Ambos módulos (sintetizador y controlador) se deben ejecutar en la misma máquina, y se debe ejecutar en orden: primero el sintetizador, y después el controlador. Si no se tienen las gafas se puede simular desde Unreal Engine.
