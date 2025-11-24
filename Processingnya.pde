import processing.serial.*;

// --- KONFIGURASI ---
// Karena sudah ada Arduino, kita matikan mode simulasi
boolean simulationMode = false; 
String portName = "COM7"; // HARDCODED ke COM7 sesuai request

Serial myPort;
PFont titleFont, dataFont, labelFont;

// Variabel Data
float suhu = 0;
float kelembaban = 0;
// String status untuk ditampilkan
String statusSuhuText = "MENUNGGU DATA...";
String statusHumText = "MENUNGGU DATA...";

// Status Output (Visualisasi)
boolean ledHijau = false;
boolean ledKuning = false;
boolean ledMerah = false;
boolean fanStatus = false;

// Variabel Animasi Fan
float fanAngle = 0;

void setup() {
  size(600, 700); // Ukuran Window
  smooth();
  
  // Setup Font (Menggunakan font bawaan sistem agar aman)
  titleFont = createFont("Arial Bold", 24);
  dataFont = createFont("Arial Bold", 48);
  labelFont = createFont("Arial", 14);

  // --- SETUP SERIAL ---
  if (!simulationMode) {
    try {
      // Langsung konek ke COM7
      myPort = new Serial(this, portName, 9600);
      myPort.bufferUntil('\n'); // Tunggu sampai baris baru (println)
      println("Berhasil terhubung ke " + portName);
    } catch (Exception e) {
      println("ERROR: Gagal terhubung ke " + portName);
      println("Pastikan Arduino tercolok dan Serial Monitor di Arduino IDE DITUTUP.");
      // Fallback ke simulasi agar aplikasi tidak crash
      simulationMode = true;
    }
  }
}

void draw() {
  background(240, 242, 245); // Background modern
  
  // 1. Update Data (Jika simulasi aktif karena error serial)
  if (simulationMode) {
    simulateData();
  }
  
  // 2. Hitung Logika Visual (Agar sinkron dengan logika Arduino)
  calculateLogic();
  
  // 3. Gambar UI
  drawHeader();
  drawSensorCard(50, 100); //
