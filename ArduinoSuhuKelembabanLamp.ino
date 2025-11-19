#include <DHT.h>
#include <SPI.h>
#include <max6675.h>

#define DHTPIN 2
#define DHTTYPE DHT22

#define CLK 6
#define CS 7
#define SO 8

#define LED_HIJAU 3
#define LED_KUNING 4
#define LED_MERAH 5
#define FAN 9

DHT dht(DHTPIN, DHTTYPE);
MAX6675 thermocouple(CLK, CS, SO);

// Fungsi untuk membaca suhu rata-rata dari MAX6675 agar stabil
float bacaSuhuRata2(int jumlah) {
  float total = 0;
  for (int i = 0; i < jumlah; i++) {
    total += thermocouple.readCelsius();
    delay(100);  // jeda antar pembacaan
  }
  return total / jumlah;
}

void setup() {
  Serial.begin(9600);
  dht.begin();
  pinMode(LED_HIJAU, OUTPUT);
  pinMode(LED_KUNING, OUTPUT);
  pinMode(LED_MERAH, OUTPUT);
  pinMode(FAN, OUTPUT);

  digitalWrite(LED_HIJAU, LOW);
  digitalWrite(LED_KUNING, LOW);
  digitalWrite(LED_MERAH, LOW);
  digitalWrite(FAN, LOW);

  Serial.println("=== Sistem Monitoring Suhu & Kelembapan ===");
  delay(1000); // beri waktu sensor siap
}

void loop() {
  // Baca suhu rata-rata dari MAX6675 (5 kali agar stabil)
  float suhu = bacaSuhuRata2(5);

  // Baca kelembapan dari DHT22
  float kelembapan = dht.readHumidity();

  // Proteksi jika sensor gagal
  if (isnan(suhu) || isnan(kelembapan)) {
    Serial.println("Error membaca sensor!");
    return;
  }

  // ----- Logika berdasarkan kondisi -----
  bool ledHijau = LOW, ledKuning = LOW, ledMerah = LOW, fan = LOW;

  if (suhu < 25 && kelembapan >= 45 && kelembapan <= 65) {            
    ledHijau = HIGH; fan = LOW;
  } 
  else if (suhu >= 25 && suhu <= 30 && kelembapan >= 45 && kelembapan <= 65) { 
    ledHijau = HIGH; ledKuning = HIGH; fan = LOW;
  } 
  else if (suhu > 30 && kelembapan >= 45 && kelembapan <= 65) {       
    ledHijau = HIGH; ledMerah = HIGH; fan = HIGH;
  } 
  else if (suhu < 25 && (kelembapan < 30 || kelembapan > 70)) {       
    ledHijau = HIGH; ledMerah = HIGH; fan = LOW;
  } 
  else if (suhu >= 25 && suhu <= 30 && (kelembapan < 30 || kelembapan > 70)) { 
    ledKuning = HIGH; ledMerah = HIGH; fan = LOW;
  } 
  else if (suhu > 30 && (kelembapan < 30 || kelembapan > 70)) {       
    ledMerah = HIGH; fan = HIGH;
  }
  else if (suhu < 25 && ((kelembapan >= 30 && kelembapan < 45) || (kelembapan > 65 && kelembapan <= 70))) {
    ledHijau = HIGH; ledKuning = HIGH; fan = LOW;
  }
  else if (suhu >= 25 && suhu <= 30 && ((kelembapan >= 30 && kelembapan < 45) || (kelembapan > 65 && kelembapan <= 70))) {
    ledHijau = HIGH; ledKuning = HIGH; fan = LOW;
  }
  else if (suhu > 30 && ((kelembapan >= 30 && kelembapan < 45) || (kelembapan > 65 && kelembapan <= 70))) {
    ledKuning = HIGH; ledMerah = HIGH; fan = HIGH;
  }
  // Update LED dan FAN
  digitalWrite(LED_HIJAU, ledHijau);
  digitalWrite(LED_KUNING, ledKuning);
  digitalWrite(LED_MERAH, ledMerah);
  digitalWrite(FAN, fan);

  // Kirim data ke Processing (GUI)
  Serial.print(suhu, 2);
  Serial.print(",");
  Serial.print(kelembapan, 2);
  Serial.print(",");
  Serial.println(fan);

  delay(2000); // jeda agar DHT22 tidak error (maks 0.5Hz)
}