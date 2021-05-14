//    Fichero: LoosySynth.ck
//    Autor: Juan Riera
    
//    Este fichero es el que contiene el objeto LoosySynth, que
//    es el Singleton que recibe paquetes, los procesa y hace
//    con esa informacion lo especificado.



 
//    Funcion auxiliar para extraer un numero indeterminado de floats de un 
//    mensaje OSC, esta pensada para los mensajes de inicializacion de acordes
//    y escalas, donde no esta claro cuantas notas van a venir.

fun float[] extractFloatsFromOscMsg(OscMsg msg){
      float noteSet[msg.typetag.length()-3]; 
      for(3 => int i; i<msg.typetag.length(); i++){
          if(msg.typetag.charAt(i) == 'f'){
                  msg.getFloat(i) => noteSet[i-3];
          } 
      }
      return noteSet;
  }
  
  
//MACROS
0 => int POSITIONMSG;
1 => int CONTROLMSG;
2 => int INITMSG;
0 => int SCALECHANGE;
1 => int CHORDCHANGE;
0 => int NEWSCALE;
1 => int SCALEPOSCHANGE;
2 => int NEWCHORD;
  
class LoosySynth{
    OscMsg msg; // Mensaje OSC
    OscIn oin; // Cliente OSC para recibir mensajes
    
    // Conexion de la cadena de seniales
    JCRev masterReverb => Delay masterDelay => Gain masterGain; 
    // Ademas del delay, metemos senial directa
    masterReverb => masterGain;
    LPF rightHandFilter => masterReverb;
    SawOsc rightHandOscillator => rightHandFilter;
    0.2 => masterGain.gain; // Bajamos volumenes
    0.2 => rightHandOscillator.gain;
    0.5 => masterReverb.gain; 
    0.6 => masterDelay.gain;
    
    // Ajustamos parametros de los efectos
    .5 => masterReverb.mix;
    .6::second => masterDelay.max => masterDelay.delay; 
    // Retroalimentacion del delay
    masterDelay => Gain delayFeedback => masterDelay;
    0.4 => delayFeedback.gain;
    
    // Creacion de los manejadores necesarios
    ScaleHandler scaleHandler;
    ChordOscHandler chordOscHandler;
    chordOscHandler.connect(masterReverb);
    
    // Cuantos centimetros hay que avanzar para cambiar de nota
    10.0 => float positionScale;
    
    // Nota do central para el oscilador, aunque va a empezar en silencio
    Std.mtof(60) => rightHandOscillator.freq;
  

//    Funcion de manejo de paquetes. Recibe un paquete y decide que hacer
//    con esa informacion, a que funciones llamar...
//    Entradas: El mensaje OSC

    fun void handleMessage(OscMsg msg){
        if(msg.typetag.charAt(0) == 'i'){
                  if(msg.getInt(0) == POSITIONMSG && msg.typetag == "iififff"){
                      // Position message
                      if (msg.getInt(1) == 0 || msg.getFloat(2)==0.0) {
                          // Si es un mensaje invalido o silencioso
                          chordOscHandler.setGain(0.0);
                         
                      } else {
                          // Ajustamos la ganancia y el filtro de los acordes
                          chordOscHandler.setGain(Math.pow(msg.getFloat(2),1/7));
                          chordOscHandler.setFilterCutoffZeroToOne(
                          msg.getFloat(2));
                      }
                      
                      if (msg.getInt(3) == 0 || scaleHandler.inSilence()){
                          // Si es un mensaje invalido o no hay escala
                          // seleccionada nos quedamos en silencio
                          0.0 => rightHandOscillator.gain;
                      } else {
                          // Ajustamos la ganancia, la nota y
                          // el filtro de la mano derecha
                          msg.getFloat(4)*0.6 => rightHandOscillator.gain;
                          scaleHandler.getRoundedFreqFromMidi(
                          msg.getFloat(5)/positionScale+60)  => 
                          rightHandOscillator.freq;
                          
                          Math.pow(Math.fabs(msg.getFloat(6)+50.0), 
                          2) => rightHandFilter.freq;
                      }
                  }
                  // Control message
                  else if(msg.getInt(0) == CONTROLMSG){
                    if(msg.typetag == "iiss"){
                      if(msg.getInt(1) == SCALECHANGE){
                          
                          //Change scale
                          scaleHandler.changeNoteSet(msg.getString(2),
                          msg.getString(3));
                      } else if(msg.getInt(1) == CHORDCHANGE){
                          //Change chord
                          
                          chordOscHandler.changeChord(msg.getString(2),msg.getString(3));
                      }
                    }
                  }
                  // Initialization message
               else if(msg.getInt(0)==INITMSG && msg.typetag.charAt(1)=='i'){
                      
                   // Scale initialization
                    if (msg.getInt(1) == NEWSCALE && msg.typetag.charAt(2)=='s'){
                              extractFloatsFromOscMsg(msg) @=> float extractedFloats[];
                              scaleHandler.addSetToTableFromMidi(msg.getString(2), extractedFloats);
                              


                  } else if(msg.getInt(1) == NEWCHORD && msg.typetag.charAt(2)=='s') {
                      // Chord initialization
                      extractFloatsFromOscMsg(msg) @=> float extractedFloats[];
                      chordOscHandler.addChordToTable(extractedFloats, msg.getString(2));
                  }
              }
                  
                
           }
       }
       
//       Funcion para arrancar el sintetizador, solo recibe el puerto
//       del que debe esperar mensajes, y la propia funcion se pone a escuchar
//       en bucle.
//       Entrada: el puerto del que recibir paquetes       

    fun void start(int port){
           
        port => oin.port;
        oin.listenAll();
        masterGain => dac;
        while(true)
        {   
            oin =>now;
            while(oin.recv(msg))
            {
              handleMessage(msg);
              
            }
            0.005::second +=> now;

                
        }
    }
}
// Inicio del sintetizador
LoosySynth s;
s.start(9999);
