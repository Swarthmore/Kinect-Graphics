import rwmidi.*;

MidiInput input;
MidiOutput output;

void setup() {
  input = RWMidi.getInputDevices()[0].createInput(this);
  output = RWMidi.getOutputDevices()[0].createOutput();
  size(127, 127);
}

void noteOnReceived(Note note) {
  println("note on " + note.getPitch());
}

void sysexReceived(rwmidi.SysexMessage msg) {
  println("sysex " + msg);
}

void keyPressed() {

  if (key == 'a')
  {
    int ret = output.sendNoteOn(15, 1, 1);
  }  
  
  if (key == 's')
  {
    int ret = output.sendNoteOn(15, 2, 1);
  }   
  
  if (key == 'z')
  {
    int ret = output.sendController(13, 1, mouseX);
  }   
  if (key == 'x')
  {
    int ret = output.sendController(14, 1, mouseY);
  }  

  if (key == 'q')
  {
    int ret = output.sendNoteOn(15, 1, 1);
  }  
  if (key == 'w')
  {
    int ret = output.sendNoteOff(16, 2, 1);
  }   

}

void draw() {
}
