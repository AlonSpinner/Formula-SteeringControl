void setup() 
{
  // put your setup code here, to run once:
Serial.begin(9600);
pinMode (2,OUTPUT);
}

void loop() 
{
    // put your main code here, to run repeatedly:
  while(Serial.available()==0)
  { 
    if (Serial.read() == 24)
    {
      digitalWrite(2,HIGH);
    }
    else if (Serial.read() == 12)
    {
      digitalWrite(2,HIGH/2);
    } 
    else
    {
      digitalWrite(2,LOW);
    }
  }
}
