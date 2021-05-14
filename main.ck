//    Fichero: main.ck
//    Autor: Juan Riera Gomez
    
//    Este fichero es el fichero raiz y es el primero al que se llama para cargar
//    todos los demas. Carga las librerias necesarias y luego ejecuta LoosySynth.ck.
    


// Creamos un array con todos los ficheros que tiene que abrir en orden
["NoteSetHandler", "ChordHandler", "ScaleHandler", "ChordOscHandler", "LoosySynth"] @=> string libs[];

// Abre los ficheros de uno en uno
for(0 => int i; i< libs.cap(); i++){
    
    // Si uno no lo encuentra o falla
    if(Machine.add(me.dir()+"/"+libs[i]+".ck")==0){
        // Informamos al usuario
        <<< libs[i] + " not found or already added!" >>>;
    }
}
        

