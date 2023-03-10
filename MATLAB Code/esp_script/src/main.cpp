#include <Arduino.h>
#include "actuatorCon.h"

// motor 1 pins
#define M1INTERR 15
#define M1READ 2
#define M1PWM 0
#define M1DIR1 4
#define M1DIR2 16
// motor 2 pins
#define M2INTERR 17
#define M2READ 5
#define M2PWM 18
#define M2DIR1 19
#define M2DIR2 21
// motor 3 pins
#define M3INTERR 34
#define M3READ 35
#define M3PWM 32
#define M3DIR1 33
#define M3DIR2 25
// motor 4 pins
#define M4INTERR 26
#define M4READ 27
#define M4PWM 11
#define M4DIR1 12
#define M4DIR2 13

String convertedData = "";
actuatorCon act1 = actuatorCon(M1INTERR, M1READ, M1PWM, M1DIR1, M1DIR2);
actuatorCon act2 = actuatorCon(M2INTERR, M2READ, M2PWM, M2DIR1, M2DIR2);
actuatorCon act3 = actuatorCon(M3INTERR, M3READ, M3PWM, M3DIR1, M3DIR2);
actuatorCon act4 = actuatorCon(M4INTERR, M4READ, M4PWM, M4DIR1, M4DIR2);

void readData()
{
  if (Serial.available())
  {
    char data = char(Serial.read());

    if (data != ' ')
    {
      convertedData = convertedData + data;
    }
    else
    {
      Serial.println(convertedData);
      convertedData = "";
    }
  }
}

void motor1ISR()
{
  if (digitalRead(M1READ))
  {
    act1.motorTics++;
  }
  else
  {
    act1.motorTics--;
  }
}

void motor2ISR()
{
  if (digitalRead(M2READ))
  {
    act2.motorTics++;
  }
  else
  {
    act2.motorTics--;
  }
}

void motor3ISR()
{
  if (digitalRead(M3READ))
  {
    act3.motorTics++;
  }
  else
  {
    act3.motorTics--;
  }
}

void motor4ISR()
{
  if (digitalRead(M4READ))
  {
    act4.motorTics++;
  }
  else
  {
    act4.motorTics--;
  }
}

void setup()
{
  Serial.begin(9600);

  attachInterrupt(digitalPinToInterrupt(M1INTERR), motor1ISR, RISING);
  attachInterrupt(digitalPinToInterrupt(M2INTERR), motor2ISR, RISING);
  attachInterrupt(digitalPinToInterrupt(M3INTERR), motor3ISR, RISING);
  attachInterrupt(digitalPinToInterrupt(M4INTERR), motor4ISR, RISING);
}

void loop()
{
  void readData();
}