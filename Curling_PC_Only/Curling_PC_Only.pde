import processing.serial.*;
import org.gamecontrolplus.*;
import ddf.minim.*;

ControlIO control;
ControlDevice device1, device2;
ControlButton button1, button2;
Minim minim, minim2, minim3, minim4, minim5;
AudioPlayer player, player2, player3, player4, player5;

// Arduino信号受け取り
Serial myPort;
String val, reserve = "0.00001";

// ゲーム内のみ変数
int n = 4, c = 0, shot = -1, c_shot = 0, bc = 0, ball_speed = 0, result_count = 0, R_result = 0, B_result = 0, rank = 0, bound_ball = 0, position = 0, collision2 = 0, collision3 = 0, recheck = 0, game_count = 0, final_count = 0, start_count = 0, rasor_count = 0, bcZR = 0;
float angle = 1.57, x_angle = 0, y_angle = 0, shot_energy = 0, shot_time, reserve_time = 0, stop_time = 0;
float[][] result;
int[] lost;

// 共通変数
int mode = 0, mode_c = 0, music_c = 0, music_c2 = 0;

// スタート変数
int press_text = 0, pc_blue1 = 255, pc_blue2 = 0, pc_red1 = 0, pc_red2 = 255, pc_green1 = 0, pc_green2 = 0;

// セレクト変数
int color_select1 = 0, color_select2 = 0, c1 = 0, c2 = 0, ready1 = 0, ready2 = 0;

// コントローラ関係（PCキーボード用ダミーフラグ併用）
ControlButton button1_A, button1_X, button1_B, button1_Y, button1_ZR, button2_left, button2_up, button2_down, button2_right, button2_LR;
boolean key1_A = false, key1_X = false, key1_B = false, key1_Y = false, key1_ZR = false;
boolean key2_left = false, key2_up = false, key2_down = false, key2_right = false, key2_LR = false;

int password = 0;
// コマンド用変数
int button_c1 = 0, button_c2 = 0, button_c3 = 0, button_c4 = 0;
int countcount = 0;
int BGM_c = 0, BGM_c2 = 0;

// キーボード用パワーチャージタイマー
float key_charge_time = 0;
boolean isCharging = false;

Ball[] balls = { 
  new Ball(480, 300, 30), 
  new Ball(1440, 300, 30),
  new Ball(480, 500, 30),
  new Ball(1440, 500, 30),
  new Ball(30, 500, 30),
  new Ball(1890, 500, 30),
  new Ball(30, 600, 30),
  new Ball(1890, 600, 30),
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
  
  // 音声ファイルの読み込み（ファイルが無い場合のエラー回避）
  try {
    player = minim.loadFile("collision.mp3");
    player2 = minim2.loadFile("button.mp3");
    player3 = minim.loadFile("mini_button.mp3");
    player4 = minim.loadFile("BGM.mp3");
    player5 = minim.loadFile("ending.mp3");
    if (player4 != null) player4.loop();
  } catch (Exception e) {
    println("Audio Load Skip");
  }

  // Arduino接続のエラー回避処理
  try {
    if (Serial.list().length > 0) {
      String portName = Serial.list()[0];
      myPort = new Serial(this, portName, 9600);
    }
  } catch (Exception e) {
    println("Serial Port Not Found. Running in PC Standalone Mode.");
  }

  // コントローラー接続のエラー回避処理
  try {
    control = ControlIO.getInstance(this);
    if (control.getDevices().size() >= 2) {
      device1 = control.getDevice(11);
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
    }
  } catch (Exception e) {
    println("Gamepads Not Found. Running in Keyboard Mode.");
  }
}

// 判定用のブール値ゲッター（コントローラー or キーボード）
boolean get1_A() { return (button1_A != null && button1_A.pressed()) || key1_A; }
boolean get1_X() { return (button1_X != null && button1_X.pressed()) || key1_X; }
boolean get1_B() { return (button1_B != null && button1_B.pressed()) || key1_B; }
boolean get1_Y() { return (button1_Y != null && button1_Y.pressed()) || key1_Y; }
boolean get1_ZR() { return (button1_ZR != null && button1_ZR.pressed()) || key1_ZR; }

boolean get2_left() { return (button2_left != null && button2_left.pressed()) || key2_left; }
boolean get2_up() { return (button2_up != null && button2_up.pressed()) || key2_up; }
boolean get2_down() { return (button2_down != null && button2_down.pressed()) || key2_down; }
boolean get2_right() { return (button2_right != null && button2_right.pressed()) || key2_right; }
boolean get2_LR() { return (button2_LR != null && button2_LR.pressed()) || key2_LR; }

void mousePressed() {
  if (mode == 1) {
    if (mouseX >= width/8 && mouseX <= width/8 + 20 && mouseY >= 700 && mouseY <= 955) {
      pc_blue1 = 255 - (mouseY - 700);
    } else if (mouseX >= 2*width/8 && mouseX <= 2*width/8 + 20 && mouseY >= 700 && mouseY <= 955) {
      pc_red1 = 255 - (mouseY - 700);
    } else if (mouseX >= 3*width/8 && mouseX <= 3*width/8 + 20 && mouseY >= 700 && mouseY <= 955) {
      pc_green1 = 255 - (mouseY - 700);
    } else if (mouseX >= 5*width/8 && mouseX <= 5*width/8 + 20 && mouseY >= 700 && mouseY <= 955) {
      pc_blue2 = 255 - (mouseY - 700);
    } else if (mouseX >= 6*width/8 && mouseX <= 6*width/8 + 20 && mouseY >= 700 && mouseY <= 955) {
      pc_red2 = 255 - (mouseY - 700);
    } else if (mouseX >= 7*width/8 && mouseX <= 7*width/8 + 20 && mouseY >= 700 && mouseY <= 955) {
      pc_green2 = 255 - (mouseY - 700);
    }
  }
}

void draw() {
  if (!get1_ZR()) bcZR = 0;
  
  // キーボード操作時の投球パワー計算
  if (isCharging) {
    key_charge_time += 0.05;
    if (key_charge_time > 4.5) key_charge_time = 0.5;
  }

  background(51);

  if ((get1_ZR() || get2_LR()) && mode_c == 0) {
    if (mode == 1 && get1_ZR()) { ready1 = 1; music_c = 1; bcZR = 1; }
    if (mode == 1 && get2_LR()) { ready2 = 1; music_c = 1; }
    if (mode == 0 && password != 10) { mode = 1; music_c = 1; }
    if (mode == -1) { mode = 0; music_c = 1; } 
    if (mode == 0 && password == 10) { 
      mode = -1;
      password = 0;
      music_c = 1;
    }
    mode_c = 1;
  }

  if (music_c == 1) {
    if (player2 != null) { player2.rewind(); player2.play(); }
    music_c = 0;
  }
  if (!(get1_ZR() || get2_LR()) && mode_c == 1) mode_c = 0;
  
  // スタート画面
  if (mode == 0) {
    fill(0, 255, 0);
    textSize(120); 
    textAlign(CENTER, CENTER); 
    text("Wonder Curling Simulator", width/2, height/3);
    textSize(80); 
    textAlign(CENTER, CENTER); 
    press_text ++;
    if (press_text > 60) {
      textSize(80); 
      textAlign(CENTER, CENTER); 
      text("Press Q or \\ Key", width/2, 2*height/3);
    }
    if (press_text >= 120) {
      press_text = 0;
    }
    if (password == 0 && get2_up()) password = 1;
    if (password == 1 && get2_up()) password = 2;
    if (password == 2 && get2_down()) password = 3;
    if (password == 3 && get2_down()) password = 4;
    if (password == 4 && get2_left()) password = 5;
    if (password == 5 && get2_right()) password = 6;
    if (password == 6 && get2_left()) password = 7;
    if (password == 7 && get2_right()) password = 8;
    if (password == 8 && get1_B()) password = 9;
    if (password == 9 && get1_A()) password = 10;
  }
  
  // セレクト画面
  else if (mode == 1) {
    fill(204);
    rect(width/2 - 4, 0, 4, 1200);
    fill(0, 255, 0);
    textSize(80); 
    textAlign(CENTER, CENTER); 
    text("Player1", width/4, height/5);
    text("Player2", 3*width/4, height/5);
    
    if (ready1 == 0) {
      // Player1 (A/Dで項目選択, W/Sで数値変更)
      if (get1_A() && color_select1 <= 1 && c1 == 0) {
        color_select1 ++;
        c1 = 1;
      } else if (get1_Y() && color_select1 >= 1 && c1 == 0) {
        color_select1 --;
        c1 = 1;
      }
      if (!(get1_A() || get1_Y())) c1 = 0;
      
      if (get1_X()) { // Wキー (上)
        if (color_select1 == 0 && pc_blue1 < 255) pc_blue1 ++;
        if (color_select1 == 1 && pc_red1 < 255) pc_red1 ++;
        if (color_select1 == 2 && pc_green1 < 255) pc_green1 ++;
      } else if (get1_B()) { // Sキー (下)
        if (color_select1 == 0 && pc_blue1 > 0) pc_blue1 --;
        if (color_select1 == 1 && pc_red1 > 0) pc_red1 --;
        if (color_select1 == 2 && pc_green1 > 0) pc_green1 --;
      }
      fill(0, 255, 255);
      if (color_select1 == 0) {
        rect(width/8 - 4, 696, 28, 263);
      } else if (color_select1 == 1) {
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
      if (get1_B()) ready1 = 0;
    }
    
    // Player2
    if (ready2 == 0) {
      if (get2_right() && color_select2 <= 1 && c2 == 0) {
        color_select2 ++;
        c2 = 1;
      } else if (get2_left() && color_select2 >= 1 && c2 == 0) {
        color_select2 --;
        c2 = 1;
      }
      if (!(get2_right() || get2_left())) c2 = 0;
      
      if (get2_up()) { // UPキー (上)
        if (color_select2 == 0 && pc_blue2 < 255) pc_blue2++;
        if (color_select2 == 1 && pc_red2 < 255) pc_red2++;
        if (color_select2 == 2 && pc_green2 < 255) pc_green2++;
      } else if (get2_down()) { // DOWNキー (下)
        if (color_select2 == 0 && pc_blue2 > 0) pc_blue2--;
        if (color_select2 == 1 && pc_red2 > 0) pc_red2--;
        if (color_select2 == 2 && pc_green2 > 0) pc_green2--;
      }
      fill(0, 255, 255);
      if (color_select2 == 0) {
        rect(5*width/8 - 4, 696, 28, 263);
      } else if (color_select2 == 1) {
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
      if (get2_down()) ready2 = 0;
    }
    
    if (ready1 == 1 && ready2 == 1) {
      mode = 2; 
    }
  }
  
  // ゲーム画面
  else if (mode == 2) {
    reserve = "0";
    if (myPort != null && myPort.available() > 0) {
      val = null;
      val = myPort.readStringUntil('\n');
      if (val != null) {
        reserve = val.trim();
        countcount++;
        reserve_time = float(reserve);
      }
    }

    if (float(reserve) == 1 && rasor_count == 0) rasor_count = 1;
    if (rasor_count == 1) start_count++;
    if (float(reserve) == 2 && start_count >= 1) {
      reserve_time = 1000.000 / start_count;
      start_count = 0;
      rasor_count = 0;
    }

    if (!(get1_ZR() || get2_LR()) && c == 1) {
      c = 0;
    }
    
    x_angle = -1 * cos(angle);
    y_angle = -1 * sin(angle);

    // Player1
    if (n % 2 == 0) {
      if (shot == -1) {
        fill(255, 0, 255);
        if (get1_Y() && position > -200) { // Aキー (左移動)
          position -= 2;
        } else if (get1_A() && position < 200) { // Dキー (右移動)
          position += 2;
        }
      } else if (shot == 0) {
        if (get1_Y() && angle > 0) {
          angle -= 0.025;
        } else if (get1_A() && angle < 3.14) {
          angle += 0.025;
        }
        if (get1_B()) shot --;
        fill(255, 0, 255);
      }
      
      if (shot == 2) {
        fill(0, 255, 0);
        textSize(60); 
        textAlign(CENTER, CENTER); 
        text("Ready", width/2, height/2);
        fill(204);
        if (get1_B()) shot -= 2;
      }

      if ((get1_ZR() && bcZR == 0 && c == 0 && n < 10) || (shot >= 1 && reserve_time <= 20 && reserve_time >= 0.0001)) {
        if (shot <= 0) {
          shot += 1; 
          music_c2 = 1;
        }
        if (shot == 1) {
          reserve_time = 0.00001;
          shot = 2;
          reserve = "0";
          start_count = 0;
          rasor_count = 0;
        }
        if (shot == 2) {
          if (reserve_time >= 0.000011 && reserve_time <= 5.0) {
            shot_energy = (reserve_time + 0.5) * (reserve_time + 0.5) * 0.05;
            shot = 3;
          }
        }
        if (shot == 3) {
          n += 1;
          balls[n - 1].cBall(x_angle, y_angle, shot_energy, position, 1050, n-1);
          shot = -1;
          angle = 1.57;
          position = 0;
        } 
        c = 1;
      }
    }
    // Player2
    else {
      if (shot == -1) {
        fill(255, 0, 255);
        if (get2_left() && position > -200) { // LEFTキー (左移動)
          position -= 2;
        } else if (get2_right() && position < 200) { // RIGHTキー (右移動)
          position += 2;
        }
      } else if (shot == 0) {
        if (get2_left() && angle > 0) {
          angle -= 0.025;
        } else if (get2_right() && angle < 3.14) {
          angle += 0.025;
        }
        if (get2_down()) shot --;
        fill(255, 0, 255);
      }
      
      if (shot == 2) {
        fill(0, 255, 0);
        textSize(60); 
        textAlign(CENTER, CENTER); 
        text("Ready", width/2, height/2);
        fill(204);
        if (get2_down()) shot -= 2;
      }

      if ((get2_LR() && c == 0 && n < 10) || (shot >= 1 && reserve_time <= 20 && reserve_time >= 0.0001)) {
        if (shot <= 0) {
          shot += 1; 
          music_c2 = 1;
        }
        if (shot == 1) {
          reserve_time = 0.00001;
          shot = 2;
          reserve = "0";
          start_count = 0;
          rasor_count = 0;
        }
        if (shot == 2) {
          if (reserve_time >= 0.000011 && reserve_time <= 5.0) {
            shot_energy = (reserve_time + 1) * (reserve_time + 1) * 0.050;
            shot = 3;
          }
        }
        if (shot == 3) {
          n += 1;
          balls[n - 1].cBall(x_angle, y_angle, shot_energy, position, 1050, n - 1);
          shot = -1;
          angle = 1.57;
          position = 0;
        } 
        c = 1;
      }
    }

    if (music_c2 == 1) {
      if (player3 != null) { player3.rewind(); player3.play(); }
      music_c2 = 0;
    }
    
    fill(0, 0, 255);
    ellipse(width/4, 300, 400, 400);
    ellipse(3*width/4, 300, 400, 400);
    fill(51);
    ellipse(width/4, 300, 300, 300);
    ellipse(3*width/4, 300, 300, 300);
    fill(255, 0, 0);
    ellipse(width/4, 300, 150, 150);
    ellipse(3*width/4, 300, 150, 150);
    fill(51);
    ellipse(width/4, 300, 50, 50);
    ellipse(3*width/4, 300, 50, 50);
    fill(204);
    
    if (n % 2 == 0) {
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
      if (collision3 == 1) collision2++;
      result[1][bc] = b.result(bc);
      result[0][bc] = bc;
      bc++;
      ball_speed += b.bs();
      bound_ball += 1;
    }
    bc = 0;
    if (n >= 10 && ball_speed > 0) {
      stop_time++;
    }
    if (stop_time >= 10) recheck = 1;
    if (ball_speed <= 0 && n >= 10 && result_count == 0 && recheck >= 1) {
      for (int i = 0; i < 10; i++) {
        for (int j = 9; j > i; j--) {
          if (result[1][j] < result[1][j-1]) {
            float t = result[1][j];
            result[1][j] = result[1][j-1];
            result[1][j-1] = t;
            t = result[0][j];
            result[0][j] = result[0][j-1];
            result[0][j-1] = t;
          }
        }
      }
      for (rank = 0; result[1][rank] <= 230; rank++ ) {
        if (result[0][rank] % 2 == 0) {
          if (result[1][rank] <= 55) {
            B_result += 5;
          } else if (result[1][rank] <= 105) {
            B_result += 3;
          } else if (result[1][rank] <= 180) {
            B_result += 2;
          } else {
            B_result += 1;
          }
        } else {
          if (result[1][rank] <= 55) {
            R_result += 5;
          } else if (result[1][rank] <= 105) {
            R_result += 3;
          } else if (result[1][rank] <= 180) {
            R_result += 2;
          } else {
            R_result += 1;
          }
        }
      }
      result_count = 1;
    }
    if (result_count == 1) final_count++;
    if (final_count >= 1 && final_count <= 499) {
      fill(0, 255, 0);
      textSize(40); 
      textAlign(CENTER, CENTER);
      if (final_count <= 100) {
        text("Now Loading.", 7*width/10, 9*height/10);
      } else if (final_count <= 200) {
        text("Now Loading..", 7*width/10, 9*height/10);
      } else if (final_count <= 300) {
        text("Now Loading...", 7*width/10, 9*height/10);
      } else if (final_count <= 400) {
        text("Now Loading....", 7*width/10, 9*height/10);
      } else {
        text("Now Loading.....", 7*width/10, 9*height/10);
      }
    }
    if (final_count >= 500) {
      mode = 3;
      final_count = 0;
    }
    
    for (int i = 0; i < (n - 1); i++) {
      for (int j = i + 1; j < n; j++) {
        int collision = balls[i].checkCollision(balls[j]);
        if (collision == 1) {
          collision2 = 1;
        }
      }
    }
    if (collision2 >= 1) {
      if (player != null) { player.rewind(); player.play(); }
      collision2 = 0;
    }
    if (n % 2 == 0) {
      fill(pc_red1, pc_green1, pc_blue1);
      ellipse(width / 4 + position + 100 * x_angle, 1050 + 100 * y_angle, 20, 20);
    } else {
      fill(pc_red2, pc_green2, pc_blue2);
      ellipse(3*width / 4 + position + 100 * x_angle, 1050 + 100 * y_angle, 20, 20);
    }
    fill(204);
    rect(width/2 - 25, 1030 - shot_energy * 300, 50, 20);

    textSize(60); 
    textAlign(CENTER, CENTER); 
    fill(pc_red1, pc_green1, pc_blue1);
    text(B_result, width/2 - 850, height/10);
    fill(pc_red2, pc_green2, pc_blue2);
    text(R_result, width/2 + 850, height/10);
  } else if (mode == 3) {
    fill(0, 255, 0);
    textSize(200); 
    textAlign(CENTER, CENTER); 
    text(B_result, width/3 - 850, height/3);
    text(R_result, 2*width/3 + 850, height/3);
    
    fill(pc_red1, pc_green1, pc_blue1);
    textSize(100);
    text("PLAYER1", width/4, height/4);
    textSize(200);
    text(B_result, width/4, height/2);

    fill(pc_red2, pc_green2, pc_blue2);
    textSize(100);
    text("PLAYER2", 3*width/4, height/4);
    textSize(200);
    text(R_result, 3*width/4, height/2);

    fill(0, 255, 0);
    textSize(100);
    text("Finish", width/2, height/2);

    press_text ++;
    if (press_text > 60) {
      textSize(80); 
      textAlign(CENTER, CENTER); 
      text("Press Q or \\ Key", width/2, 3*height/4);
    }
    if (press_text >= 120) {
      press_text = 0;
    }
    if ((get1_ZR() && get1_X()) || (get2_LR() && get2_up())) mode = 6;
    
  } else if (mode == 4) {
    final_count += 2;
    if (get1_ZR() || get2_LR()) final_count += 2;
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
    if ((-1)*(float)final_count + 3410 <= height/2) {
      final_count -= 2;
      if (get1_ZR() || get2_LR()) final_count -= 2;
    }
    if ((get1_ZR() || get2_LR()) && (-1)*(float)final_count + 3410 <= height/2 + 100) {
      final_count = 0;
      mode = 6;
    }
  } else if (mode == -1) {
    fill(0, 255, 0);
    textSize(80); 
    textAlign(CENTER, CENTER); 
    fill(0, 0, 255);
    text("Player1", width/4, height/5);
    text(B_result, width/4, height/2);
    fill(255, 0, 0);
    text("Player2", 3*width/4, height/5);
    text(R_result, 3*width/4, height/2);
    if (get2_up() && button_c1 == 0) { R_result ++; button_c1 = 1; }
    if (get2_down() && button_c2 == 0) { R_result --; button_c2 = 1; }
    if (get1_X() && button_c3 == 0) { B_result ++; button_c3 = 1; }
    if (get1_B() && button_c4 == 0) { B_result --; button_c4 = 1; }
    if (!get2_up() && button_c1 == 1) button_c1 = 0;
    if (!get2_down() && button_c2 == 1) button_c2 = 0;
    if (!get1_X() && button_c3 == 1) button_c3 = 0;
    if (!get1_B() && button_c4 == 1) button_c4 = 0;
  } else if (mode == 6) {
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
    balls[7].cBall(0, 0, 0, 1890 - width/4, 600, 7);
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

// ------------------------------------------
// キーボード入力処理（キー押下判定）
// ------------------------------------------
void keyPressed() {
  // Player 1 (左手側: WASD, Q)
  if (key == 'a' || key == 'A') key1_Y = true;    // 左 (A)
  if (key == 'd' || key == 'D') key1_A = true;    // 右 (D)
  if (key == 'w' || key == 'W') key1_X = true;    // 上 / 数値増加 (W)
  if (key == 's' || key == 'S') key1_B = true;    // 下 / 数値減少 / キャンセル (S)
  
  if (key == 'q' || key == 'Q') {                 // 決定・ショット (Q)
    key1_ZR = true;
    if (mode == 2 && (n % 2 == 0) && shot == 2 && !isCharging) {
      isCharging = true;
      key_charge_time = 0.5;
    }
  }

  // Player 2 (右手側: 矢印キー, \, Enter)
  if (keyCode == LEFT)  key2_left = true;        // 左
  if (keyCode == RIGHT) key2_right = true;       // 右
  if (keyCode == UP)    key2_up = true;          // 上 / 数値増加
  if (keyCode == DOWN)  key2_down = true;        // 下 / 数値減少 / キャンセル
  
  if (key == '\\' || key == '|' || keyCode == ENTER) { // 決定・ショット (\ または Enter)
    key2_LR = true;
    if (mode == 2 && (n % 2 != 0) && shot == 2 && !isCharging) {
      isCharging = true;
      key_charge_time = 0.5;
    }
  }
}

void keyReleased() {
  // Player 1
  if (key == 'a' || key == 'A') key1_Y = false;
  if (key == 'd' || key == 'D') key1_A = false;
  if (key == 'w' || key == 'W') key1_X = false;
  if (key == 's' || key == 'S') key1_B = false;
  
  if (key == 'q' || key == 'Q') {
    key1_ZR = false;
    if (mode == 2 && (n % 2 == 0) && shot == 2 && isCharging) {
      isCharging = false;
      reserve_time = key_charge_time; // キー長押し時間でパワー設定
    }
  }

  // Player 2
  if (keyCode == LEFT)  key2_left = false;
  if (keyCode == RIGHT) key2_right = false;
  if (keyCode == UP)    key2_up = false;
  if (keyCode == DOWN)  key2_down = false;
  
  if (key == '\\' || key == '|' || keyCode == ENTER) {
    key2_LR = false;
    if (mode == 2 && (n % 2 != 0) && shot == 2 && isCharging) {
      isCharging = false;
      reserve_time = key_charge_time; // キー長押し時間でパワー設定
    }
  }
}

void stop() {
  if (player != null) player.close();
  if (player2 != null) player2.close();
  if (player3 != null) player3.close();
  if (player4 != null) player4.close();
  if (player5 != null) player5.close();
  if (minim != null) minim.stop();
  if (minim2 != null) minim2.stop();
  if (minim3 != null) minim3.stop();
  if (minim4 != null) minim4.stop();
  if (minim5 != null) minim5.stop();
  super.stop();
}
