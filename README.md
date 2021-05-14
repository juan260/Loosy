## Loosy
Sintetizador en realidad mixta que constituye el TFG de Juan Riera Gomez.

# Distribución de carpetas
Se compone de dos módulos separados aquí por carpetas. En una está el módulo de síntesis LoosySynth desarrollado en formato ChucK. En otro está el módulo controlador, diseñado para ejecutarse en unas gafas Hololens 2, y desarrollado en Unreal Engine. Lo que se incluye son las clases necesarias. 

# Ficheros de configuración
Se incluyen también los ficheros de configuración. El fichero de configuración del módulo de síntesis se debe almacenar en la misma carpeta que los módulos de código. En el caso del controlador, en la carpeta Content del proyecto que se cree. 

# Instrucciones de ejecución y herramientas necesarias.
Los ficheros de chuck se pueden ejecutar a través de la herramienta de desarrollo miniAudicle. También se pueden ejecutar con le comando:

  chuck main.ck
  
El módulo de controlador se ejecuta en Unreal Engine, así que se debe crear un proyecto e importar las clases. 

Ambos módulos se deben ejecutar en la misma máquina, y se debe ejecutar en orden: primero el sintetizador, y después el controlador.
