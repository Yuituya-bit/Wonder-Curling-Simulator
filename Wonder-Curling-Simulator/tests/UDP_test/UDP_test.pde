import hypermedia.net.*;

//無線受信用変数
UDP udp;
//final String IP = "localhost";
final String IP = "192.168.1.3";
final int PORT = 2000;

void setup(){
  udp = new UDP(this, 2000/*,"192.168.1.3"*/);
  udp.listen( true ); 
}
void draw(){

}

void receive( byte[] data, String ip, int port ) {
  int message = int(data[0]);
  println( "receive: \""+message+"\" from "+ ip +" on port " + port );
  //println(int(message));
}
