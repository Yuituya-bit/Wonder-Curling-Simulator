import processing.opengl.*;
float m = 10.0; // 円の質量
PVector position = new PVector(400, 250); // 円の初期位置
PVector velocity = new PVector(5, -100); // 円の初期速度
PVector acceleration = new PVector(0, 0); // 円の初期加速度

void setup() {
  size(displayWidth,displayHeight);
  camera(0, 0, 0, 0,0,0,0,0,0);
  translate(width/2, height/2, 0);
}

void draw() {
  background(255);
  // 力を計算（この例では重力のみ）
  PVector force = new PVector(0,  0); // F = maにおけるFを(0, 1)と下向きに一定の力が働いているように定義
  
  // 力から加速度を計算
  acceleration = PVector.div(force, m); // F=maを変形して、a=F/mとし、aを求めた
  
  // 速度と位置を更新
  velocity.add(acceleration); //加速度を速度に加えて速度を更新
  position.add(velocity); //位置に速度を加えて、位置を更新
  
  // 地面に到達したら反射
  if (position.y > 375) {
    position.y = 375; // 位置を修正
    velocity.y *= -0.9; // 反射と同時にエネルギー損失
  }
  if (position.y < -475) {
    position.y = -475; // 位置を修正
    velocity.y *= -0.9; // 反射と同時にエネルギー損失
  }
  if (position.x > 575) {
    position.x = 575; // 位置を修正
    velocity.x *= -1; // 反射と同時にエネルギー損失
  }
  if (position.x < 225) {
    position.x = 225; // 位置を修正
    velocity.x *= -1; // 反射と同時にエネルギー損失
  }
  velocity.x *= 0.995;
  velocity.y *= 0.995;
  // オブジェクトの描画
  ellipse(position.x, position.y, 50, 50);
  line(200, 400, 200, -500);
  line(600, 400, 600, -500);
  line(200, -500, 600, -500);
  line(200, 400, 600, 400);
}
