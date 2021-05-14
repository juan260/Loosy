//    Fichero: ChordOscHandler.ck
//    Autor: Juan Riera
    
//    Fichero que contiene la clase ChordOscHandler
//    que se encarga de gestionar las voces de los acordes,
//    que nota suena en cada oscilador, sus volumenes etc.


public class ChordOscHandler{
    10 => int maxNotes; // Numero maximo de notas
    1 => int currentlySoundingNotes; // Numero de notas sonando actualmente
    SawOsc oscillators[maxNotes]; // Array de osciladores
    LPF filter; // Filtro de paso bajo
    float gain; // Ganancia
    
    // Conectamos los osciladores al filtro
    for(0 => int i; i<maxNotes;i++){
        oscillators[i] => filter;
    }
    
    // Creamos un manejador de acordes
    ChordHandler chordHandler;
    // Silenciamos los osciladores
    setGain(0.0);
    
    
//        Funcion para cuantos osciladores tienen que estar sonando. 
//        
//        Entrada: el numero de notas
//        Salida: el numero de notas sonando, si no coincide con el de la entrada
//            es que ya estan sonando el maximo de notas, o que la entrada era 
//            menor que 1.
    
    fun int setCurrentlySoundingNotes(int n){
        Std.ftoi(Math.min(Math.max(1,n), maxNotes)) => currentlySoundingNotes;
        setGain(gain);
        return currentlySoundingNotes;
    }
    
     
//        Funcion para cambiar el numero maximo de notas que pueden sonar
//        a la vez en un acorde. Esto cambiara la longitud del array de
//        osciladores.
//        
//        Entrada: el numero maximo de notas.
//        Salida: el numero maximo de notas que pueden sonar en un acorde.

    fun int setMaxNotes(int n){
        
        SawOsc @ newOscillators[n];
        int i;
        for(0=>i;i<maxNotes;i++){
               oscillators[i] @=> newOscillators[i];
        }
        for(;i<n;i++){
               createNewOsc() @=> newOscillators[i]; 
                newOscillators[i] => filter;
        }
        newOscillators @=> oscillators; 
        Std.ftoi(Math.max(1.0,n)) => maxNotes;
        return maxNotes;
    }
    
     
//        Funcion para conectar la salida de este modulo a otro de ChucK.
//        Entrada: el modulo al que conectar
    
    fun void connect(UGen output){
        filter => output;
    }
    
    
//        Funcion para cambiar la ganancia general de los osciladores.
//        Reparte la ganancia entre los osciladores. 
//        Entrada: nueva ganancia.
    
    fun void setGain(float g){
        0.7 * g => g;
        if(inSilence())
            0.0=>g;
        int i;
        for(0 =>i; i<currentlySoundingNotes;i++){
           g/currentlySoundingNotes => oscillators[i].gain;
        }
        while(i<maxNotes){
            0.0 => oscillators[i].gain;
            i++;
        }
        g => gain;
    }
        
   
     
//        Funcion que recibe un valor entre 0 y 1 y
//        lo multiplica por 5000 antes de asignarselo a la
//        frecuencia de corte del filtro paso bajo.
//        
//        Entrada: valor entre 0 y 1
    
    fun void setFilterCutoffZeroToOne(float cutoff){
        cutoff*5000 => filter.freq;
    }
    
    
//        Funcion que comprueba si hay algun acorde seleccionado o no.
//        Salida: 1 si esta en silencio (sin escala seleccionada) o 0 si no.
    
    fun int inSilence(){
        return chordHandler.inSilence();
    }
    
    
//        Funcion para cambiar de acorde.
//        Entrada: nota raiz del acorde, y tipo (mayor, menor...)
//        Salida: 0 en caso de que no se haya podido cambiar y 1 en caso de exito.

    fun int changeChord(string root, string quality){
        
        chordHandler.changeNoteSet(root, quality);
        chordHandler.getCurrentChordNotes()@=> float newChord[];
        if(newChord==NULL)
            return 0;
        int i;
        for(0=>i; i<Math.min(newChord.cap(), maxNotes);i++){
            <<< newChord[i]>>>;
            Std.mtof(newChord[i]) => oscillators[i].freq;
        }
        
        setCurrentlySoundingNotes(Std.ftoi(Math.min(newChord.cap(), maxNotes));
        return 1;
    }
    
//        Funcion auxiliar para crear un nuevo oscilador
//        Salida: un oscilador nuevo en silencio
    
    fun SawOsc createNewOsc(){
        SawOsc osc;
        0.0 => osc.gain;
        return osc;
    }
    
    
//        Funcion para aniadir un acorde nuevo.
//        Entrada: las notas del acorde y el nombre del acorde.
//        Salida: la tabla de conjuntos de notas (en este caso de acordes)
    
    fun float[][] addChordToTable(float notes[], string name){
       if(notes.cap()>maxNotes){
           setMaxNotes(notes.cap());
       }
        return chordHandler.addSetToTable(name,notes);
    }
} 