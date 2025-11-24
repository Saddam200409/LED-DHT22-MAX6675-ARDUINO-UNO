import processing.serial.*;

// --- KONFIGURASI ---
boolean simulationMode = false; // Ubah ke true jika alat belum colok
String portName = "COM7";       // Port asli Arduino (jangan diubah agar tetap connect)

Serial myPort;
PFont titleFont, dataFont, labelFont;

// Variabel Data
float suhu = 0;
float kelembaban = 0;

// String status
String statusSuhuText = "MENUNGGU DATA...";
String statusHumText = "MENUNGGU DATA...";

// Status Output
boolean ledHijau = false;
boolean ledKuning = false;
boolean ledMerah = false;
boolean fanStatus = false;

// Variabel Animasi Fan
float fanAngle = 0;

void setup() {
  size(600, 700);
  smooth();
  
  // Setup Font
  titleFont = createFont("Arial Bold", 24);
  dataFont = createFont("Arial Bold", 48);
  labelFont = createFont("Arial", 14);

  // Setup Serial
  if (!simulationMode) {
    try {
      myPort = new Serial(this, portName, 9600);
      myPort.bufferUntil('\n'); 
      println("Berhasil terhubung ke " + portName);
    } catch (Exception e) {
      println("Gagal koneksi ke " + portName + ". Masuk mode simulasi.");
      simulationMode = true;
    }
  }
}

void draw() {
  background(240, 242, 245);
  
  if (simulationMode) {
    simulateData();
  }
  
  calculateLogic();
  
  drawHeader();
  drawSensorCard(50, 100);
  drawLedCard(50, 320);
  drawFanCard(50, 500);
}

void calculateLogic() {
  ledHijau = false; ledKuning = false; ledMerah = false; fanStatus = false;
  
  // Logika persis dari tabel/Arduino
  if (suhu < 25 && kelembaban >= 45 && kelembaban <= 65) {            
     ledHijau = true; fanStatus = false;
     statusSuhuText = "TERLALU DINGIN"; statusHumText = "IDEAL";
  } 
  else if (suhu >= 25 && suhu <= 30 && kelembaban >= 45 && kelembaban <= 65) { 
     ledHijau = true; ledKuning = true; fanStatus = false;
     statusSuhuText = "NORMAL"; statusHumText = "IDEAL";
  } 
  else if (suhu > 30 && kelembaban >= 45 && kelembaban <= 65) {       
     ledHijau = true; ledMerah = true; fanStatus = true;
     statusSuhuText = "TERLALU PANAS"; statusHumText = "IDEAL";
  } 
  else if (suhu < 25 && (kelembaban < 30 || kelembaban > 70)) {       
     ledHijau = true; ledMerah = true; fanStatus = false;
     statusSuhuText = "TERLALU DINGIN"; statusHumText = "TIDAK IDEAL";
  } 
  else if (suhu >= 25 && suhu <= 30 && (kelembaban < 30 || kelembaban > 70)) { 
     ledKuning = true; ledMerah = true; fanStatus = false;
     statusSuhuText = "NORMAL"; statusHumText = "TIDAK IDEAL";
  } 
  else if (suhu > 30 && (kelembaban < 30 || kelembaban > 70)) {       
     ledMerah = true; fanStatus = true;
     statusSuhuText = "TERLALU PANAS"; statusHumText = "TIDAK IDEAL";
  }
  else if (suhu < 25 && ((kelembaban >= 30 && kelembaban < 45) || (kelembaban > 65 && kelembaban <= 70))) {
     ledHijau = true; ledKuning = true; fanStatus = false;
     statusSuhuText = "TERLALU DINGIN"; statusHumText = "WARNING";
  }
  else if (suhu >= 25 && suhu <= 30 && ((kelembaban >= 30 && kelembaban < 45) || (kelembaban > 65 && kelembaban <= 70))) {
     ledHijau = true; ledKuning = true; fanStatus = false;
     statusSuhuText = "NORMAL"; statusHumText = "WARNING";
  }
  else if (suhu > 30 && ((kelembaban >= 30 && kelembaban < 45) || (kelembaban > 65 && kelembaban <= 70))) {
     ledKuning = true; ledMerah = true; fanStatus = true;
     statusSuhuText = "TERLALU PANAS"; statusHumText = "WARNING";
  }
}

void drawHeader() {
  noStroke();
  fill(70, 130, 180);
  rect(0, 0, width, 70);
  fill(255);
  textFont(titleFont);
  textAlign(CENTER, CENTER);
  text("Sistem Monitoring Suhu & Kelembapan", width/2, 35);
}

void drawSensorCard(float x, float y) {
  fill(255); stroke(200);
  rect(x, y, width - 100, 180, 15);
  
  fill(100); textFont(labelFont); textAlign(LEFT);
  // --- BAGIAN INI SUDAH DIUBAH KE 4KB02 ---
  text("DATA SENSOR REALTIME (4KB02)", x + 20, y + 30);
  // ----------------------------------------
  stroke(220); line(x+20, y+40, x + width - 120, y+40);
  
  float centerX1 = x + (width-100)/4;
  float centerY = y + 100;
  textAlign(CENTER);
  fill(100); text("Suhu", centerX1, y + 65);
  
  if (suhu > 30) fill(220, 50, 50); 
  else if (suhu < 25) fill(50, 100, 220);
  else fill(50, 200, 100);
  
  textFont(dataFont);
  text(nf(suhu, 0, 1) + "°C", centerX1, centerY + 10);
  drawStatusBox(centerX1, centerY + 40, statusSuhuText);

  float centerX2 = x + (width-100)*0.75;
  fill(100); textFont(labelFont);
  text("Kelembapan", centerX2, y + 65);
  
  fill(100, 100, 200); 
  textFont(dataFont);
  text(nf(kelembaban, 0, 1) + "%", centerX2, centerY + 10);
  drawStatusBox(centerX2, centerY + 40, statusHumText);
}

void drawStatusBox(float x, float y, String txt) {
  rectMode(CENTER);
  noStroke();
  if(txt.contains("PANAS") || txt.contains("TIDAK")) fill(255, 200, 100);
  else if (txt.contains("DINGIN")) fill(150, 220, 255);
  else if (txt.contains("WARNING")) fill(255, 255, 150);
  else fill(200, 255, 200);
  
  rect(x, y, 140, 25, 10);
  fill(50); textFont(labelFont);
  text(txt, x, y + 5);
  rectMode(CORNER);
}

void drawLedCard(float x, float y) {
  fill(255); stroke(200);
  rect(x, y, width - 100, 150, 15);
  
  fill(100); textAlign(LEFT);
  text("INDIKATOR STATUS (LED)", x + 20, y + 30);
  stroke(220); line(x+20, y+40, x + width - 120, y+40);
  
  float gap = (width - 100) / 4;
  drawSingleLed(x + gap, y + 90, "Hijau", color(0, 255, 0), ledHijau);
  drawSingleLed(x + gap*2, y + 90, "Kuning", color(255, 200, 0), ledKuning);
  drawSingleLed(x + gap*3, y + 90, "Merah", color(255, 0, 0), ledMerah);
}

void drawSingleLed(float x, float y, String label, color c, boolean isOn) {
  noStroke();
  if (isOn) {
    fill(c, 100); ellipse(x, y, 60, 60);
    fill(c); ellipse(x, y, 40, 40);
  } else {
    fill(50); ellipse(x, y, 40, 40);
  }
  fill(80); textAlign(CENTER);
  text(label, x, y + 40);
}

void drawFanCard(float x, float y) {
  fill(255); stroke(200);
  rect(x, y, width - 100, 150, 15);
  
  fill(100); textAlign(LEFT);
  text("KONDISI KIPAS", x + 20, y + 30);
  stroke(220); line(x+20, y+40, x + width - 120, y+40);
  
  float fanX = x + (width - 100)/2;
  float fanY = y + 90;
  
  if (fanStatus) fanAngle += 0.2;
  
  pushMatrix();
  translate(fanX, fanY);
  rotate(fanAngle);
  noStroke();
  if (fanStatus) fill(50, 150, 255); else fill(150);
  for (int i = 0; i < 4; i++) { ellipse(0, -25, 15, 50); rotate(HALF_PI); }
  fill(50); ellipse(0, 0, 15, 15);
  popMatrix();
  
  fill(80); textAlign(CENTER);
  text(fanStatus ? "Status: AKTIF" : "Status: NONAKTIF", fanX, fanY + 50);
}

void serialEvent(Serial p) {
  try {
    String inString = p.readStringUntil('\n');
    if (inString != null) {
      inString = trim(inString);
      String[] data = split(inString, ',');
      if (data.length >= 2) {
        suhu = float(data[0]);
        kelembaban = float(data[1]);
      }
    }
  } catch (Exception e) {
    println("Error: " + e);
  }
}

void simulateData() {
  suhu = map(mouseX, 0, width, 15, 40);
  kelembaban = map(mouseY, 0, height, 100, 0);
  fill(255, 0, 0);
  textAlign(CENTER);
  text("MODE SIMULASI (Check COM Port)", width/2, height-20);
}
