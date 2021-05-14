//    Fichero: ChordHandler.ck
//    Autor: Juan Riera
//    
//    Fichero que contiene la clase ChordHandler, que es una clase que hereda de
//    NoteSetHandler para almacenar acordes.

public class ChordHandler extends NoteSetHandler{
    

    
//        Funcion que obtiene las notas del acorde 
//        que este seleccionado en ese momento.
    
//        Salidas: un array de floats con las notas midi de los acordes
    d
    fun float[] getCurrentChordNotes(){
        if(isKnownNoteSet(currentSet)==0){
            return NULL;
        } else {
           
            float chordNotes[noteTables[currentSet].cap()];
            for(0=>int i;i<noteTables[currentSet].cap();i++){
                noteTables[currentSet][i]+currentTranspose => chordNotes[i];
            }
            return chordNotes;
        }
    } 
}