import processing.serial.*;
import org.gamecontrolplus.*;
import ddf.minim.*;
 
ControlIO control;
ControlDevice device1, device2;
ControlButton button1, button2;
Minim minim, minim2, minim3, minim4, minim5;
AudioPlayer player, player2, player3, player4, player5;
//Arduino信号受け取り
Serial myPort;
String val, reserve = "0.00001";
//ゲーム内のみ変数
  int n = 4, c = 0, shot = -1, c_shot = 0, bc = 0, ball_speed = 0, result_count = 0, R_result = 0, B_result = 0, rank = 0, bound_ball = 0, position = 0,  collision2 = 0, collision3 = 0, recheck = 0, game_count = 0, final_count = 0, start_count = 0, rasor_count = 0, bcZR = 0;
  float angle = 1.57, x_angle = 0, y_angle = 0, shot_energy = 0, shot_time, reserve_time = 0, stop_time = 0;
  float[][] result;
  int[] lost;
//共通変数
  int mode = 0, mode_c = 0, music_c = 0, music_c2 = 0;
//スタート変数
  int press_text = 0, pc_blue1 = 255, pc_blue2 = 0, pc_red1 = 0, pc_red2 = 255, pc_green1 = 0, pc_green2 = 0;
//セレクト変数
  int color_select1 = 0, color_select2 = 0, c1 = 0, c2 = 0, ready1 = 0, ready2 = 0;
//コントローラ関係
  ControlButton button1_A, button1_X, button1_B, button1_Y, button1_ZR, button2_left, button2_up, button2_down, button2_right, button2_LR;
  int password = 0;
//コマンド用変数
  int button_c1 = 0, button_c2 = 0, button_c3 = 0, button_c4 = 0;
  int countcount = 0;
  int BGM_c = 0, BGM_c2 = 0;

Ball[] balls =  { 
  new Ball(480, 300, 30), 
  new Ball(1440, 300, 30),
  new Ball(480, 500, 30),
  new Ball(1440, 500, 30),
  new Ball(30, 500, 30),
  new Ball(1890, 500, 30),
  new Ball(30, 600, 30),
  new Ball(1890,600, 30),
  new Ball(30, 700, 30),
  new Ball(1890, 700, 30)
};

void setup() {
  println(width / 4);
  println(3 * width / 4);
  fullScreen();
  result = new float[10][10];
  lost = new int[10];
  minim = new Minim(this);
  minim2 = new Minim(this);
  minim3 = new Minim(this);
  minim4 = new Minim(this);
  minim5 = new Minim(this);
  player = minim.loadFile("collision.mp3");
  player2 = minim2.loadFile("button.mp3");
  player3 = minim.loadFile("mini_button.mp3");
  player4 = minim.loadFile("BGM.mp3");
  player5 = minim.loadFile("ending.mp3");
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  control = ControlIO.getInstance(this);
  println("使えるデバイス: " + control.getDevices());
  device1 = control.getDevice(11);//使うのは0番目（getDevice(0)でも大丈夫）
  device2 = control.getDevice(10);
  button1_A = device1.getButton(0);
  button1_X = device1.getButton(1);
  button1_B = device1.getButton(2);
  button1_Y = device1.getButton(3);
  button1_ZR = device1.getButton(15);
  button2_left = device2.getButton(0);
  button2_up = device2.getButton(2);
  button2_down = device2.getButton(1);
  button2_right = device2.getButton(3);
  button2_LR = device2.getButton(15);
  player4.loop();
}
void mousePressed(){
  if(mode == 1){
    if(mouseX >= width/8 && mouseX <= width/8 + 20 && mouseY >= 700 && mouseY <= 955){
      pc_blue1 = 255 - (mouseY - 700);
    } else if(mouseX >= 2*width/8 && mouseX <= 2*width/8 + 20 && mouseY >= 700 && mouseY <= 955){
      pc_red1 = 255 - (mouseY - 700);
    } else if(mouseX >= 3*width/8 && mouseX <= 3*width/8 + 20 && mouseY >= 700 && mouseY <= 955){
      pc_green1 = 255 - (mouseY - 700);
    } else if(mouseX >= 5*width/8 && mouseX <= 5*width/8 + 20 && mouseY >= 700 && mouseY <= 955){
      pc_blue2 = 255 - (mouseY - 700);
    } else if(mouseX >= 6*width/8 && mouseX <= 6*width/8 + 20 && mouseY >= 700 && mouseY <= 955){
      pc_red2 = 255 - (mouseY - 700);
    } else if(mouseX >= 7*width/8 && mouseX <= 7*width/8 + 20 && mouseY >= 700 && mouseY <= 955){
      pc_green2 = 255 - (mouseY - 700);
    }
  }
}

void draw() {
  if(!(button1_ZR.pressed())) bcZR = 0;
  for (int i = 0; i < device2.getNumberOfButtons(); i++) {
    ControlButton button = device2.getButton(i);
    if (button.pressed())println(i);//押したボタンの数字を表示
  }
  background(51);
  //println(password + ", " + mode_c);
  if((button1_ZR.pressed() || button2_LR.pressed()) && mode_c == 0){
    if(mode == 1 && button1_ZR.pressed()) {ready1 = 1; music_c = 1; bcZR = 1;}
    if(mode == 1 && button2_LR.pressed()) {ready2 = 1; music_c = 1;}
    if(mode == 0 && password != 10) {mode = 1; music_c = 1;}
    if(mode == -1) {mode = 0; music_c = 1;} 
    if(mode == 0 && password == 10){ 
      mode = -1;
      password = 0;
      music_c = 1;
    }
    mode_c = 1;
  }
  if(music_c == 1){player2.rewind(); player2.play(); music_c = 0;}
  if(!(button1_ZR.pressed() || button2_LR.pressed()) && mode_c == 1) mode_c = 0;
  
  //スタート画面
  if(mode == 0){
    fill(0, 255, 0);
    textSize(120); 
    textAlign(CENTER, CENTER); 
    text("Wonder Curling Simulator", width/2, height/3);
    textSize(80); 
    textAlign(CENTER, CENTER); 
    press_text ++;
    if(press_text > 60){
      textSize(80); 
      textAlign(CENTER, CENTER); 
      text("Press ZR or ZL Button", width/2, 2*height/3);
    }
    if(press_text >= 120){
      press_text = 0;
    }
    if(password == 0 && button2_up.pressed()) password = 1;
    if(password == 1 && button2_up.pressed()) password = 2;
    if(password == 2 && button2_down.pressed()) password = 3;
    if(password == 3 && button2_down.pressed()) password = 4;
    if(password == 4 && button2_left.pressed()) password = 5;
    if(password == 5 && button2_right.pressed()) password = 6;
    if(password == 6 && button2_left.pressed()) password = 7;
    if(password == 7 && button2_right.pressed()) password = 8;
    if(password == 8 && button1_B.pressed()) password = 9;
    if(password == 9 && button1_A.pressed()) password = 10;
  }
  
  //セレクト画面
  else if(mode == 1){
    fill(204);
    rect(width/2 - 4, 0, 4, 1200);
    fill(0, 255, 0);
    textSize(80); 
    textAlign(CENTER, CENTER); 
    text("Player1", width/4, height/5);
    text("Player2", 3*width/4, height/5);
    if(ready1 == 0){
      
    //Player1
    if(button1_A.pressed() && color_select1 <= 1 && c1 == 0){
      color_select1 ++;
      c1 = 1;
    } else if(button1_Y.pressed() && color_select1 >= 1 && c1 == 0){
      color_select1 --;
      c1 = 1;
    }
    if(!(button1_A.pressed() || button1_Y.pressed())) c1 = 0;
    if(button1_X.pressed()){
      if(color_select1 == 0 && pc_blue1 < 255) pc_blue1 ++;
      if(color_select1 == 1 && pc_red1 < 255) pc_red1 ++;
      if(color_select1 == 2 && pc_green1 < 255) pc_green1 ++;
    } else if(button1_B.pressed()){
      if(color_select1 == 0 && pc_blue1 > 0) pc_blue1 --;
      if(color_select1 == 1 && pc_red1 > 0) pc_red1 --;
      if(color_select1 == 2 && pc_green1 > 0) pc_green1 --;
    }
    fill(0, 255, 255);
    if(color_select1 == 0){
      rect(width/8 - 4, 696, 28, 263);
    } else if(color_select1 == 1){
      rect(2*width/8 - 4, 696, 28, 263);
    } else {
      rect(3*width/8 - 4, 696, 28, 263);
    }
    fill(0, 0, 255);
    rect(width/8, 700, 20, 255);
    fill(255, 0, 0);
    rect(2*width/8, 700, 20, 255);
    fill(0, 255, 0);
    rect(3*width/8, 700, 20, 255);
    fill(255);
    ellipse(width/8+10, 700 + (255 - pc_blue1), 30, 30);
    ellipse(2*width/8+10, 700 + (255 - pc_red1), 30, 30);
    ellipse(3*width/8+10, 700 + (255 - pc_green1), 30, 30);
    ellipse(width/4, 480, 200, 200);
    fill(pc_red1, pc_green1, pc_blue1);
    ellipse(width/4, 480, 100, 100);
    } else {
      fill(pc_red1, pc_green1, pc_blue1);
      textSize(60); 
      textAlign(CENTER, CENTER); 
      text("Ready", width/4, height/2);
      if(button1_B.pressed()) ready1 = 0;
    }
    
    //Player2
    if(ready2 == 0){
    if(button2_right.pressed() && color_select2 <= 1 && c2 == 0){
      color_select2 ++;
      c2 = 1;
    } else if(button2_left.pressed() && color_select2 >= 1 && c2 == 0){
      color_select2 --;
      c2 = 1;
    }
    if(!(button2_right.pressed() || button2_left.pressed())) c2 = 0;
    if(button2_up.pressed()){
      if(color_select2 == 0 && pc_blue2 < 255) pc_blue2++;
      if(color_select2 == 1 && pc_red2 < 255) pc_red2++;
      if(color_select2 == 2 && pc_green2 < 255) pc_green2++;
    } else if(button2_down.pressed()){
      if(color_select2 == 0 && pc_blue2 > 0) pc_blue2--;
      if(color_select2 == 1 && pc_red2 > 0) pc_red2--;
      if(color_select2 == 2 && pc_green2 > 0) pc_green2--;
    }
    fill(0, 255, 255);
    if(color_select2 == 0){
      rect(5*width/8 - 4, 696, 28, 263);
    } else if(color_select2 == 1){
      rect(6*width/8 - 4, 696, 28, 263);
    } else {
      rect(7*width/8 - 4, 696, 28, 263);
    }
    fill(0, 0, 255);
    rect(5*width/8, 700, 20, 255);
    fill(255, 0, 0);
    rect(6*width/8, 700, 20, 255);
    fill(0, 255, 0);
    rect(7*width/8, 700, 20, 255);
    fill(255);
    ellipse(5*width/8+10, 700 + (255 - pc_blue2), 30, 30);
    ellipse(6*width/8+10, 700 + (255 - pc_red2), 30, 30);
    ellipse(7*width/8+10, 700 + (255 - pc_green2), 30, 30);
    ellipse(3*width/4, 480, 200, 200);
    fill(pc_red2, pc_green2, pc_blue2);
    ellipse(3*width/4, 480, 100, 100);
    } else {
      fill(pc_red2, pc_green2, pc_blue2);
      textSize(60); 
      textAlign(CENTER, CENTER); 
      text("Ready", 3*width/4, height/2);
      if(button2_down.pressed()) ready2 = 0;
    }
    
    if(ready1 == 1 && ready2 == 1){
      mode = 2; 
    }
  }
  
  //ゲーム画面
  else if(mode == 2){
    //if(BGM_c == 0){player4.play(); BGM_c = 1;}
  reserve = "0";
  if(myPort.available() > 0){
    val = null;
    val = myPort.readStringUntil('\n');
    if(val != null){
        reserve = val.trim();
        println(countcount++);
        reserve_time = float(reserve);
        println(float(reserve) + ", " + reserve_time);
        //println(float(reserve));
    }
  }
  if(float(reserve) == 1 && rasor_count == 0) rasor_count = 1;
  if(rasor_count == 1) start_count++;
  //println(rasor_count);
  if(float(reserve) == 2 && start_count >= 1){
    println("2ON!");
    reserve_time = 1000.000 / start_count;
    println("1000 ÷ " + start_count + " = " + reserve_time);
    start_count = 0;
    rasor_count = 0;
  }
  if(!(button1_ZR.pressed() || button2_LR.pressed()) && c == 1){
    c = 0;
  }
  
  x_angle = -1 * cos(angle);
  y_angle = -1 * sin(angle);
//Player1
  if(n % 2 == 0){
    if(shot == -1){
    fill(255, 0, 255);
    //text("position", 3*width/10, 9*height/10);
    if(button1_Y.pressed() && position > -200){
      position -= 2;
    } else if(button1_A.pressed() && position < 200){
      position += 2;
    }
  }else if(shot == 0){
    if(button1_Y.pressed() && angle > 0){
      angle -= 0.025;
    } else if(button1_A.pressed() && angle < 3.14){
      angle += 0.025;
    }
    if(button1_B.pressed()) shot --;
    fill(255, 0, 255);
    //text("angle", 3*width/10, 9*height/10);
  } //以下else if消去 
  /*else if(shot == 1){
    if(c_shot == 0){
      shot_energy += 0.01;
      if(shot_energy >= 1){
        c_shot = 1;
      }
    }else if(c_shot == 1){
      shot_energy -= 0.01;
      if(shot_energy <= 0){
        c_shot = 0;
      }
    } 
  }*/
  
  if(shot == 2){
    fill(0, 255, 0);
    textSize(60); 
    textAlign(CENTER, CENTER); 
    text("Ready", width/2, height/2);
    fill(204);
    if(button1_B.pressed()) shot -= 2;
  }
    if((button1_ZR.pressed() && bcZR == 0 && c == 0 && n < 10) || (shot >= 1 && reserve_time <= 20 && reserve_time >= 0.0001)){
     if(shot <= 0/*1*/){
       shot += 1; 
       music_c2 = 1;
     }
    if(shot == 1){
      reserve_time = 0.00001;
      shot = 2;
      reserve = "0";
      start_count = 0;
      rasor_count = 0;
    }
    if(shot == 2){
       if(reserve_time >= 0.000011 && reserve_time <= 5.0){
          shot_energy = (reserve_time + 0.5) * (reserve_time + 0.5) * 0.05;
          println(reserve_time);
          shot = 3;
          println("OK");
       }
       
    }
    
    if(shot == 3/*2*/){
      n += 1;
      balls[n - 1].cBall(x_angle, y_angle, shot_energy, position, 1050, n-1);
      shot = -1;
      angle = 1.57;
      position = 0;
    } 
    c = 1;
  }
  }
//player2
  else {
    if(shot == -1){
    fill(255, 0, 255);
    //text("position", 3*width/10, 9*height/10);
    if(button2_left.pressed() && position > -200){
      position -= 2;
    } else if(button2_right.pressed() && position < 200){
      position += 2;
    }
  }else if(shot == 0){
    if(button2_left.pressed() && angle > 0){
      angle -= 0.025;
    } else if(button2_right.pressed() && angle < 3.14){
      angle += 0.025;
    }
    if(button2_down.pressed()) shot --;
    fill(255, 0, 255);
    //text("angle", 3*width/10, 9*height/10);
  } //以下else if消去 
  /*else if(shot == 1){
    if(c_shot == 0){
      shot_energy += 0.01;
      if(shot_energy >= 1){
        c_shot = 1;
      }
    }else if(c_shot == 1){
      shot_energy -= 0.01;
      if(shot_energy <= 0){
        c_shot = 0;
      }
    } 
  }*/
  
  if(shot == 2){
    fill(0, 255, 0);
    textSize(60); 
    textAlign(CENTER, CENTER); 
    text("Ready", width/2, height/2);
    fill(204);
    if(button2_down.pressed()) shot -= 2;
  }
    if((button2_LR.pressed() && c == 0 && n < 10) || (shot >= 1 && reserve_time <= 20 && reserve_time >= 0.0001)){
     if(shot <= 0/*1*/){
       shot += 1; 
       music_c2 = 1;
     }
    if(shot == 1){
      reserve_time = 0.00001;
      shot = 2;
      reserve = "0";
      start_count = 0;
      rasor_count = 0;
    }
    
    if(shot == 2){
       if(reserve_time >= 0.000011 && reserve_time <= 5.0){
          shot_energy = (reserve_time + 1) * (reserve_time + 1) * 0.050;
          println(reserve_time);
          shot = 3;
          println("OK");
       }
    }
    
    if(shot == 3/*2*/){
      n += 1;
      balls[n - 1].cBall(x_angle, y_angle, shot_energy, position, 1050, n - 1);
      shot = -1;
      angle = 1.57;
      position = 0;
    } 
    c = 1;
  }
  }
  //println(ball_speed);
  //println(shot);
  if(music_c2 == 1){
    player3.rewind();
    player3.play();
    music_c2 = 0;
  }
  
  fill(0, 0, 255);
  ellipse(width/4, 300, 400, 400);
  ellipse(3*width/4, 300, 400, 400);
  fill(51);
  ellipse(width/4, 300, 300, 300);
  ellipse(3*width/4, 300, 300, 300);
  fill(255, 0, 0);
  ellipse(width/4, 300, 150,150);
  ellipse(3*width/4, 300, 150, 150);
  fill(51);
  ellipse(width/4, 300, 50, 50);
  ellipse(3*width/4, 300, 50, 50);
  fill(204);
  
  if(n % 2 == 0){
    ellipse(width/4 + position, 1050, 40, 40);
  } else {
    ellipse(3*width/4 + position, 1050, 40, 40);
  }
  rect(width/2 - 4, 0, 4, 1200);
  
  ball_speed = 0;
  for (Ball b : balls) {
    b.update();
    b.display(bc, pc_red1, pc_green1, pc_blue1, pc_red2, pc_green2, pc_blue2);
    collision3 = b.checkBoundaryCollision(bc);
    if(collision3 == 1) collision2++;
    result[1][bc] = b.result(bc);
    result[0][bc] = bc;
    bc++;
    ball_speed += b.bs();
    bound_ball += 1;
  }
  bc = 0;
  if(n >= 10 && ball_speed > 0){
    stop_time++;
  }
  if(stop_time >= 10) recheck = 1;
  if(ball_speed <= 0 && n >= 10 && result_count == 0 && recheck >= 1){
    for(int i = 0; i < 10; i++){
      for(int j = 9; j > i; j--){
        if(result[1][j] < result[1][j-1]){
          float t = result[1][j];
          result[1][j] = result[1][j-1];
          result[1][j-1] = t;
          t = result[0][j];
          result[0][j] = result[0][j-1];
          result[0][j-1] = t;
        }
      }
    }
    for(rank = 0; result[1][rank] <= 230; rank++ ){
      if(result[0][rank] % 2 == 0){
        if(result[1][rank] <= 55){
          B_result += 5;
        } else if(result[1][rank] <= 105){
          B_result += 3;
        } else if(result[1][rank] <= 180){
          B_result += 2;
        } else {
          B_result += 1;
        }
      } else {
        if(result[1][rank] <= 55){
          R_result += 5;
        } else if(result[1][rank] <= 105){
          R_result += 3;
        } else if(result[1][rank] <= 180){
          R_result += 2;
        } else {
          R_result += 1;
        }
      }
    }
    result_count = 1;
  }
  if(result_count == 1) final_count++;
  if(final_count >= 1 && final_count <= 499){
    fill(0, 255, 0);
    textSize(40); 
    textAlign(CENTER, CENTER);
    if(final_count <= 100){
      text("Now Loading.", 7*width/10, 9*height/10);
    } else if(final_count <= 200){
      text("Now Loading..", 7*width/10, 9*height/10);
    } else if(final_count <= 300){
      text("Now Loading...", 7*width/10, 9*height/10);
    } else if(final_count <= 400){
      text("Now Loading....", 7*width/10, 9*height/10);
    }else {
      text("Now Loading.....", 7*width/10, 9*height/10);
    }
  }
  if(final_count >= 500){
    mode = 3;
    final_count = 0;
  }
  
  /*print(result[1][0]);
  print(", ");
  print(result[1][1]);
  print(", ");
  print(result[1][2]);
  print(", ");
  print(result[1][3]);
  print(", ");
  print(result[1][4]);
  print(", ");
  print(result[1][5]);
  print(", ");
  print(result[1][6]);
  print(", ");
  print(result[1][7]);
  print(", ");
  print(result[1][8]);
  print(", ");
  println(result[1][9]);*/
  for(int i = 0; i < (n - 1); i++){
    for(int j = i + 1; j < n; j++){
      int collision = balls[i].checkCollision(balls[j]);
      if(collision == 1){
        collision2 = 1;
      }
    }
  }
  if(collision2 >= 1){
    player.rewind();
    player.play();
    collision2 = 0;
  }
  if(n % 2 == 0){
    fill(pc_red1, pc_green1, pc_blue1);
    ellipse(width / 4 + position + 100 * x_angle, 1050 + 100 * y_angle, 20, 20);
  } else {
    fill(pc_red2, pc_green2, pc_blue2);
    ellipse(3*width / 4 + position + 100 * x_angle, 1050 + 100 * y_angle, 20, 20);
  }
  fill(204);
  rect(width/2 - 25, 1030 - shot_energy * 300, 50, 20);
  //rect(260, 0, 40, 1200);
  //rect(1600, 0, 40, 1200);
    textSize(60); 
    textAlign(CENTER, CENTER); 
    fill(pc_red1, pc_green1, pc_blue1);
    text(B_result, width/2 - 850, height/10);
    fill(pc_red2, pc_green2, pc_blue2);
    text(R_result, width/2 + 850, height/10);
  } else if(mode == 3){
    fill(0, 255, 0);
    textSize(200); 
    textAlign(CENTER, CENTER); 
    text(B_result, width/3 - 850, height/3);
    text(R_result, 2*width/3 + 850, height/3);
    //if(B_result > R_result){
      fill(pc_red1, pc_green1, pc_blue1);
      textSize(100);
      text("PLAYER1", width/4, height/4);
      textSize(200);
      text(B_result, width/4, height/2);
    //} else if(B_result < R_result){
      fill(pc_red2, pc_green2, pc_blue2);
      textSize(100);
      text("PLAYER2", 3*width/4, height/4);
      textSize(200);
      text(R_result, 3*width/4, height/2);
    //} 
    //else {
      fill(0, 255, 0);
      textSize(100);
      text("Finish", width/2, height/2);
    //}
    press_text ++;
    if(press_text > 60){
      textSize(80); 
      textAlign(CENTER, CENTER); 
      text("Press (ZR & X) or (ZL & ↑) Button", width/2, 3*height/4);
    }
    if(press_text >= 120){
      press_text = 0;
    }
    if((button1_ZR.pressed() && button1_X.pressed()) || (button2_LR.pressed() && button2_up.pressed())) mode = 6;
    
  } else if(mode == 4){
    //if(BGM_c2 == 0){player5.play(); BGM_c2 = 1;}
    final_count+=2;
    if(button1_ZR.pressed() || button2_LR.pressed()) final_count+=2;
    fill(255, 255, 0);
    textSize(80);
    textAlign(CENTER, CENTER);
    text("Programming(Processing)", width/2, (-1)*(float)final_count + 1300.0);
    text("HAYASHI YUKI", width/2, (-1)*(float)final_count + 1390.0);
    text("Programming(Arduino) & Component Adjustment", width/2, (-1)*(float)final_count + 1540.0);
    text("MIWA TAKUTO", width/2, (-1)*(float)final_count + 1630.0);
    text("Machinery & Created Presentation", width/2, (-1)*(float)final_count + 1780.0);
    text("INAGAKI YUTO", width/2, (-1)*(float)final_count + 1870.0);
    text("Teacher", width/2, (-1)*(float)final_count + 2020.0);
    text("MIYAKE SHOKO", width/2, (-1)*(float)final_count + 2110.0);
    textSize(100);
    text("Presented by", width/2, (-1)*(float)final_count + 2610.0);
    text("Gifu National College of Technology", width/2, (-1)*(float)final_count + 2760.0);
    text("We look forward to welcoming you!", width/2, (-1)*(float)final_count + 3410.0);
    if((-1)*(float)final_count + 3410 <= height/2) {
      final_count-=2;
      if(button1_ZR.pressed() || button2_LR.pressed()) final_count-=2;
    }
    if((button1_ZR.pressed() || button2_LR.pressed()) && (-1)*(float)final_count + 3410 <= height/2 + 100){
      final_count = 0;
      mode = 6;
    }
  } else if(mode == -1){
    fill(0, 255, 0);
    textSize(80); 
    textAlign(CENTER, CENTER); 
    fill(0, 0, 255);
    text("Player1", width/4, height/5);
    text(B_result, width/4, height/2);
    fill(255, 0, 0);
    text("Player2", 3*width/4, height/5);
    text(R_result, 3*width/4, height/2);
    if(button2_up.pressed() && button_c1 == 0){ R_result ++; button_c1 = 1;}
    if(button2_down.pressed() && button_c2 == 0){ R_result --; button_c2 = 1;}
    if(button1_X.pressed() && button_c3 == 0) { B_result ++; button_c3 = 1;}
    if(button1_B.pressed() && button_c4 == 0) { B_result --; button_c4 = 1;}
    if(!button2_up.pressed() && button_c1 == 1) button_c1 = 0;
    if(!button2_down.pressed() && button_c2 == 1) button_c2 = 0;
    if(!button1_X.pressed() && button_c3 == 1) button_c3 = 0;
    if(!button1_B.pressed() && button_c4 == 1) button_c4 = 0;
  } else if(mode == 6){
    mode = 0;
    n = 4;
    ready1 = 0;
    ready2 = 0;
    result_count = 0;
    R_result = 0;
    B_result = 0;
    recheck = 0;
    stop_time = 0;
    balls[0].cBall(0, 0, 0, 0, 300, 0);
    balls[1].cBall(0, 0, 0, 0, 300, 1);
    balls[2].cBall(0, 0, 0, 0, 500, 2);
    balls[3].cBall(0, 0, 0, 0, 500, 3);
    balls[4].cBall(0, 0, 0, 30 - 3* width/4, 500, 4);
    balls[5].cBall(0, 0, 0, 1890 - width/4, 500, 5);
    balls[6].cBall(0, 0, 0, 30 - 3* width/4, 600, 6);
    balls[7].cBall(0, 0, 0, 1890 - width/4,600, 7);
    balls[8].cBall(0, 0, 0, 30 - 3*width/4, 700, 8);
    balls[9].cBall(0, 0, 0, 1890 - width/4, 700, 9);
    pc_blue1 = 255;
    pc_blue2 = 0;
    pc_red1 = 0;
    pc_red2 = 255;
    pc_green1 = 0;
    pc_green2 = 0;
  }
}

void stop(){
  player.close();
  player2.close();
  player3.close();
  player4.close();
  player5.close();
  minim.stop();
  minim2.stop();
  minim3.stop();
  minim4.stop();
  minim5.stop();
  super.stop();
}
