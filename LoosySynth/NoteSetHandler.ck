 
//    Fichero: NoteSetHandler.ck
//    Autor: Juan Riera
    
//    Este fichero contiene la clase abstracta NoteSetHandler, que 
//    esta diseniada para contener conjuntos de notas, de manera que 
//    tanto el manejador de escalas como el manejador de acordes heredaran
//    de ella.


// ABSTRACT CLASS
public class NoteSetHandler{
    
    127 => int maxNoteTableSize; // Tamanio maximo de la tabla, 127 es el 
                                 // numero de notas midi posibles
    
    50 => int maxNoteSets;       // Maximo numero de conjuntos de notas posibles,
                                 // se estima que nadie necesitara mas de 50
    
    float noteTables[0][maxNoteTableSize]; // Tabla de conjuntos de notas
    string knownNotes[maxNoteSets]; // Tabla con las claves del diccionario
    0 => int currentKnownNotes; // Entero que almacena el ultimo indice
    string currentSet; // Conjunto de notas en uso actualmente
    0 => int currentTranspose; // Transposicion actual respecto de la nota raiz
    
    initNoteSetTable() @=> noteTables; // Inicializar la tabla de conjuntos
    
   // Abrimos el archivo de configuracion e importamos lo necesario
    FileIO file;
    if(file.open(me.dir() + "/noteTranspositions.conf", FileIO.READ)==false){
        <<< "noteTranspositions.conf not found!!">>>;
        Machine.crash();
    }
    int roots[0];
    string knownRoots[0];
    int knownRootsCount;
    int ival;
    string sval;
    // Read "noteName"
    file => sval;
    // Read "Transposition"
    file => sval;
    while(true)
    {
         file => sval;
        if(file.eof()) break;
            
         file => ival;
        if(file.eof()) break;
            
         ival => roots[Std.itoa(sval.charAt(0))];
         Std.itoa(sval.charAt(0)) => knownRoots[Std.itoa(knownRootsCount)];
         knownRootsCount++;
         
    }
    file.close();
    
//       Funcion que se encarga de cambiar el conjunto de notas actual.
//        
//        Entradas: un string con el nombre del conjunto al que se quiere cambiar
//        Salidas: 1 si es un conjunto conocido, -1 si es un conjunto desconocido
//            al que por tanto no se puede cambiar
    
    fun int changeNoteSet(string newSet){
        <<<"ChangeAttempt", newSet >>>;
        for(0=>int i;i<currentKnownNotes;i++){
            if(knownNotes[i]==newSet){
                newSet => currentSet;
                <<< "Set Changed", newSet >>>;
                return 1;
            }
        }
        return -1;
    }
    
     
//        Funcion para cambiar el conjunto de notas y la transposicion
//        a la vez.
//        
//        Entradas: un string con la nota raiz, y otro con el nuevo nombre 
//            del conjunto (por ejemplo "C" "mayor")
//        Salidas: 1 en caso de exito, -1 en caso de error
    
    fun int changeNoteSet(string root, string name){
        getTranspositionFromNoteName(root) => int newTransp;
        if(newTransp < -12)
            return -1;
        newTransp => currentTranspose;
        return changeNoteSet(name);
    }
    
    
//        Funcion que comprueba si no hay ninguna escala elegida.
//        
//        Salidas: 1 en caso afirmativo, 0 en caso negativo
    
    fun int inSilence(){
        return currentSet == "Silence";
    }
    
     
//        Funcion que realiza el modulo positivo de dos numeros.
//        Por ejemplo 5 % 4 = 1
//                    7 % 4 = 3
//                    -1 % 3 = 2 (en ChucK seria -1)
//        Entradas: primer termino de la operacion y segundo termino
//        Salidas: el modulo positivo (el resto de dividir uno entre el otro)
    
    fun int positiveModulo(int a, int m){
        return (a%m+m)%m;
    }
    
    
//        Funcion que devuelve una tabla inicializada de conjuntos de notas,
//        Solo contiene el conjunto "Silence" que marca que no hay ningun conjunto
//        seleccionado.
    
    fun float[][] initNoteSetTable() {
        float auxiliarTable[maxNoteTableSize];
        for (0 => int i; i<maxNoteTableSize; i++){
            -10000000 => auxiliarTable[i];
        }
        auxiliarTable @=> noteTables["Silence"];
        "Silence" => currentSet;
        0 => currentTranspose;
        
        currentSet => knownNotes[currentKnownNotes];
        currentKnownNotes++;

        return noteTables;
    }   

    
//        Responde a la pregunta: es este conjunto de notas conocido?
//        Entradas: el nombre del conjunto de notas.
//        Salidas: 1 si es conocido, 0 si no
    
    fun int isKnownNoteSet(string name){
        for(0 => int i; i<currentKnownNotes; i++){
            if(knownNotes[i] == name){
                
                return 1;
            }
        }
        return 0;
    }
    

//        Aniade el nombre de un conjunto de notas. Esta funcion no debe ser llamada
//        por el usuario a menos que sepa bien lo que esta haciendo.
//        Entradas: el nombre del conjunto
//        Salidas: 1 si todo ha ido bien, 0 si el conjunto ya existia, -1 si no 
//        caben mas conjuntos. En este caso se aniade reemplazando el ultimo.

    fun int addNoteSetName(string name){
        
        name => knownNotes[currentKnownNotes];
        if(isKnownNoteSet(name)){
            <<< name, "already exists!">>>;
            return 0;
           
        }
        if(currentKnownNotes<maxNoteSets-1){
                
                currentKnownNotes++;
        }else{
            <<<"Maximum number of scales reached!">>>;
            return -1;
        }
        return 1;
        
    }
    

//        Aniadir un conjunto nuevo a la tabla de conjuntos
//        Entradas: string con le nombre, y array de floats con las notas midi
 //       Salidas: la tabla de conjuntos de notas.

    fun float[][] addSetToTable(string name, float notes[]){
        <<< "Adding note set", name>>>;
        notes @=> noteTables[name];
        addNoteSetName(name);
        return noteTables;
    }
    

//        Obtiene la tansposicion asociada  aun nombre de nota.
//        Entrada: el nombre de la nota (por ejemplo: C, C#, Ab, Abb, Abbb...)
//        Salida: la transposicion asociada o -100000 en caso de error.

    fun int getTranspositionFromNoteName(string note){
        if(note.charAt(0) > 'a')
            note.setCharAt(0, note.charAt(0)+'a'-'A');
        for(0=>int i; i<knownRootsCount; i++){
            if(knownRoots[Std.itoa(i)]==Std.itoa(note.charAt(0))){
                0 => int flatsSharps;
                
                for(1=> int j;j<note.length();j++){
                    if(note.charAt(j) == '#')
                        flatsSharps++;
                    if(note.charAt(j) == 'b')
                        flatsSharps--;
                }
                return roots[Std.itoa(note.charAt(0))]+flatsSharps; 
            }
        }
        
        <<< "Invalid note name", note>>>;
        return -100000;       
    }
    
}