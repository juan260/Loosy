//    Fichero: ScaleHandler.ck
//    Autor: Juan Riera
    
//    Este fichero contiene la clase ScaleHandler, que hereda de NoteSetHandler.
//    Esta clase gestiona la organizacion de escalas. Ademas tiene funcionalidad
//    para devolver una funcion continua entre notas, en lugar de una funcion 
//    discreta como ocurriria en otros instrumentos como el piano.


public class ScaleHandler extends  NoteSetHandler{ 
            
    4 => int roundNoteWeight; // Constante de aproximacion para las notas.
                              // Cuanto mas alta es, mas vertical sera la fucion
                              // de cambio de notas
    
    
//        Redondeo especial, con una funcion exponencial, para que el cambio de 
//        nota sea suave.
//        Entradas: nota base, nota mas cercana, distancia entre notas en el 
//            intervalo de la escala en el que nos hallamos
//        Salidas: el redondeo especial
    
    fun float specialRound(float startingPoint, float target, float distance){       
        return Math.pow(2*(startingPoint-target)/distance, 
        2*roundNoteWeight+1)*distance/2 + target;

    }    

    
//        Funcion que aproxima la nota midi que recibe
//        a su equivalente dentro de la escala con el redondeado especial.
//        Entradas: la nota midi que indexea dentro de la escala
//        Salidas: la nota midi correspondiente en la escala redondeada
    
    fun float getRoundedMidi(float midiNote){
        
        midiNote => float original;
        Math.max(0, midiNote) => midiNote; 
        Math.min(maxNoteTableSize-2, midiNote) => midiNote;
        Std.ftoi(Math.round(midiNote)) => int midiNoteIndex;
        noteTables[currentSet][midiNoteIndex]+currentTranspose => midiNote;
        
        1.0 => float distance;
        midiNote => float startingPoint;
        original-Math.floor(original) => float decimalPart;
         
        if(original > Math.round(original)){
            noteTables[currentSet][midiNoteIndex+1]+currentTranspose-midiNote => 
            distance; 
            midiNote + decimalPart*distance => startingPoint;
       }
        else {
            midiNote-noteTables[currentSet][midiNoteIndex-1]-currentTranspose => 
            distance;    
            midiNote - (1-decimalPart)*distance => startingPoint;
          
        }
        return specialRound(startingPoint, midiNote, distance);
    }

       
     
//        Redondeo de la frecuencia a nota midi. Convierte la frecuencia a nota
//        midi estandar y llama a getRoundedFreqFromMidi.
//        Entradas: la frecuencia
//        Salidas: frecuencia redondeada dentro de la escala
    
    fun float getRoundedFreq(float freq){
                
                Std.ftom(freq) => float midiNote;
                return getRoundedFreqFromMidi(midiNote);
            }
    
    
//        Redondeo del midi de entrada dentro de la escala 
//        de getRoundedMidi, pero convirtiendolo a frecuencia al final.
//        Entradas: nota midi
//        Salida: la frecuencia con el redondeado especial dentro de la escala.
    
    fun float getRoundedFreqFromMidi(float midiNote){
        
        return Std.mtof(getRoundedMidi(midiNote));
    }
        
    
    
//        Funcion que genera la tabla de notas de la escala completa en do
//        a partir de los intervalos de la misma. 
        
//        Entradas: array de intervalos de la escala.
//        Salidas: la tabla de la escala.
    
    fun float[] genScaleTable(float scale[]) {
        float scaleTable[maxNoteTableSize];
        int startingMidiNote;
        float currentMidiNote;
        int i;
        60 => startingMidiNote;
        60 => i;
        startingMidiNote => currentMidiNote;
        currentMidiNote => scaleTable[i];
        // Rellenamos la tabla hacia arriba
        while(i<maxNoteTableSize-1){
            i++; 
            scale[positiveModulo((i-startingMidiNote-1),scale.cap())] +=> 
            currentMidiNote;
            currentMidiNote => scaleTable[i];
            
            if(currentMidiNote>126)
                break;
            
        }
        // Terminamos de rellenar hacia arriba
        while(i<maxNoteTableSize-1){
            i++;
            126 => scaleTable[i];
        }
        // Rellenamos la tabla hacia abajo
        startingMidiNote => i;
        startingMidiNote => currentMidiNote;
        while(i>0){
            i--;
            scale[positiveModulo((i-startingMidiNote),scale.cap())] -=> 
            currentMidiNote;
            
            currentMidiNote => scaleTable[i];
            
            if(currentMidiNote<0)
                break;
            
        }
        // Terminamos de rellenar hacia abajo
        while(i>0){
            i--;
            0 => scaleTable[i];
        }
        return scaleTable;
        
        
        }
     
//        Aniade una nueva escala a la tabla de escalas. 
//        Recibe el nombre de la escala
//        y un array con los intervalos de la misma, 
//        que se le pasa a genScaleTable
//        para generar la escala completa, y eso se guarda en la tabla de escalas.
        
//        Entradas: nombre e intervalos de la escala.
//        
//        Salidas: la tabla de escalas completa con todas las escalas
//            hasta el momento indexadas por nombre como en un diccionario.
   
    fun float[][] addSetToTable(string name, float notes[]){
        <<< "Adding scale", name>>>;
        genScaleTable(notes) @=> noteTables[name];
        addNoteSetName(name);
        return noteTables;
    }
    
     
//        Aniade una nueva escala a la tabla de escalas. 
//        Recibe el nombre de la escala
//        y un array con una repeticion de la misma, se calculan los intervalos
//        y se le pasan a addSetToTable
//        para generar la escala completa, guardarla en la tabla de escalas.
//        
//        Entradas: nombre y  trozo de la escala que se espera que 
//            sea una repeticion
//            completa, es decir, que si se repiten los intervalos
//            de esta entrada hacia arriba y hacia abajo aparezcan todas 
//            las notas de la escala.
//    
//        Salidas: la tabla de escalas completa con todas las escalas
//            hasta el momento indexadas por nombre como en un diccionario.
//   
        
    fun float[][] addSetToTableFromMidi(string name, float midiNotes[]){
        float scale[midiNotes.cap()-1];
        for(0=>int i; i<scale.cap();i++){
            midiNotes[i+1]-midiNotes[i] => scale[i];
        }
        return addSetToTable(name, scale);
    }
}