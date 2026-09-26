import processing.serial.*;

//Arduino
  Serial myPort;
  String data;
  String[] values;
  
float val_X = 0, val_Y = 0, val_Z = 0;
float angle_X = 0, angle_Y = 0, angle_Z = 0; // 回転角度

void setup() {
  size(displayWidth, displayHeight, P3D); // P3Dを指定する。
  noStroke();
  /*String[] ports = Serial.list();
  for (int i = 0; i < ports.length; i++) {
    println(i + ": " + ports[i]); // 各ポートを表示
  }*/
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 2400);
}

void draw() {
  background(0);
  lights();
  translate(width / 2, height / 2);
  
  if (myPort.available() > 0) {
    data = myPort.readStringUntil('\n'); // 改行までの文字列を読む
    if (data != null) {
      // データをカンマで分割
      values = split(trim(data), ',');
      if (values.length == 3) { // 3つの値が受信された場合
        val_X = float(values[0]) - 1800;
        val_Y = float(values[1]) - 1800;
        val_Z = float(values[2]) - 1900;
      
        // ここで受け取った値を使って何か処理をする
        println("Value 1: " + val_X);
        println("Value 2: " + val_Y);
        println("Value 3: " + val_Z);
      }
    }
  }
  
  angle_Z = val_X / 800 * PI;
  angle_Y = val_Y / 800 * PI;
  /*if(val_Z <= 0){
    angle_Z  = angle_Z * -1;
    angle_Y +=  angle_Y * -1; 
  }*/
  
  // 回転を適用
  rotateY(angle_X);
  rotateX(angle_Y);
  rotateZ(angle_Z);
  
  fill(255);
  noStroke();
  box(500, 80, 500); 
  /*
  // 大きな球を描く
  fill(150, 150, 250);
  sphere(100);
  

  
  // 小さい球を配置する位置
  float offset = 100; // 大きな球の半径と同じ値を使う
  
  // 上  
  fill(0, 250, 0);
  pushMatrix();
  translate(0, -offset, 0);
  sphere(30); // 小さい球の半径
  popMatrix();
  
  // 下
  fill(0, 100, 0);
  pushMatrix();
  translate(0, offset, 0);
  sphere(30);
  popMatrix();
  
  // 左
  fill(250, 0, 0);
  pushMatrix();
  translate(-offset, 0, 0);
  sphere(30);
  popMatrix();
  
  // 右
  fill(100, 0, 0);
  pushMatrix();
  translate(offset, 0, 0);
  sphere(30);
  popMatrix();
  
  // 前
  fill(250, 250, 250);
  pushMatrix();
  translate(0, 0, -offset);
  sphere(30);
  popMatrix();
  
  // 後ろ
  fill(0, 0, 0);
  pushMatrix();
  translate(0, 0, offset);
  sphere(30);
  popMatrix();*/
}

void keyPressed(){
  if(key == 'x') angle_X += PI / 100;
  if(key == 'y') angle_Y += PI / 100;
  if(key == 'z') angle_Z += PI / 100;
}
