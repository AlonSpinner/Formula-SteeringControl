
int pwmpin = 3;
int val;
int dutycycle;

void setup() {
  // put your setup code here, to run once:
Serial.begin(9600);
pinMode (pwmpin , OUTPUT);
}

void loop() {
    // put your main code here, to run repeatedly:
  while(Serial.available()==0){ }
  
  val = Serial.read();
  dutycycle = map(val,0,48,0,255);
  analogWrite(pwmpin,dutycycle);

}
 
  

  
  
  
