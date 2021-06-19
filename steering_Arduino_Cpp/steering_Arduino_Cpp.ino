
int pwmpin = 3;         // select the output pin for the PWM
int val;                // value [0,48] 
int dutycycle;          // variable to send the correct pwm value to controller


void setup() {
  // put your setup code here, to run once:
Serial.begin(9600);
pinMode (pwmpin , OUTPUT);
analogWrite(pwmpin,127); // when restart, send steering to 0 deg
}

void loop() {
    // put your main code here, to run repeatedly:
    
  if(Serial.available()>0){
    val = Serial.read();
    dutycycle = map(val,0,48,0,255);
    analogWrite(pwmpin,dutycycle);
  }
}
 
  

  
  
  
