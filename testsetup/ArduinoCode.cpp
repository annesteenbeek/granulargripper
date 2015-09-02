// testsetup.ino
#include <Servo.h>
Servo myservo; // create servo object

int pumppin = 12;  // The pin for controlling the pump
int pressurepin = 0; // pin that reads air pressure
int strainpin = 1; // the pin that reads the strain
int servopin = 9; 
int refpin = 2; // pin to measure voltage for reference

int minangle = 110; // angle of the servo
int maxangle = 40; // maximum angle of the servo
int angle = minangle; // counter for the angle, start at minimum
unsigned long starttime; // time since test started
long interval = 15;  // time between servo movements in millisecodns
long previousMillis = 0; // stores last time servo moved

int restartbutton = 2; // pin for restart button
int startbutton = 3; // pin for start button

int restartlastvalue = 0; // store last value of restart button
int startlastvalue = 0; // store last value of start button

int restartvalue = 0; // store restart button value
int startvalue = 0; // store start button value 
int teststart = 0;
int done = 0; // sign to mark test has finished 

int pressureV; // the air pressure
int strainV; // the strain
int refV; // reference voltage
float pressure; // air pressure in [Kpa]
int writetimer; // write to serial every ...ms

int triggerpressure = 65;  // the pressure at which the servo starts pulling

void setup() {
	pinMode(pumppin, OUTPUT); // set pump to output
	digitalWrite(pumppin, LOW); // set pump low so it won't run at startup
	myservo.attach(servopin); // attatch servo
	myservo.write(minangle); // set to start position
	Serial.begin(9600); // set baud rate

	pinMode(restartbutton, INPUT);
	pinMode(startbutton,INPUT);
}

void loop() {
	pressureV = analogRead(pressurepin); // read the pressure (0V to 5V mapped over 0 - 1024)
	strainV = analogRead(strainpin); // read the strain (0V to 5V mapped over 0 - 1024)
	refV = analogRead(refpin);
	restartvalue = digitalRead(restartbutton);
	startvalue = digitalRead(startbutton);
	pressure = (float) (pressureV+0.095*refV)/(refV*0.009); // calculate correct pressure

	if(startvalue== HIGH){
		teststart = 1;
		starttime = millis();
		digitalWrite(pumppin, HIGH); // start pumping 
	}
	
	if(restartvalue== HIGH || done == 1){
		if (restartlastvalue == LOW){
			teststart = 0; // stop testing
			digitalWrite(pumppin, LOW); // stop pumping
			myservo.write(minangle);
			angle = minangle;
			if(done == 0){
				Serial.print('[');
				Serial.print((float) millis()-starttime); Serial.print(' '); // print time since test started
				Serial.print(strainV); Serial.print(' '); // print strain
				Serial.print(pressure); Serial.print(' '); // print pressure
				Serial.print(myservo.read()); Serial.print(' '); // print serial position
				Serial.print(1);
				Serial.println(']');  // Terminator statement
			}
			done = 0;
		}
	}
	restartlastvalue = restartvalue;

	// things to do when test is active
	if (teststart == 1){ 
		// when the air pressure is below the trigger pressure, start pulling
		if(pressure < triggerpressure){ 
			// run the servo
			unsigned long currentMillis = millis();

			if (currentMillis - previousMillis > interval){
				previousMillis = currentMillis; // store millis
				myservo.write(angle--);
			}

			if (angle==maxangle){ // when the servo is at it's max angle, stop measurment
				done = 1;
			}
		}

			Serial.print('[');
			Serial.print((float) millis()-starttime); Serial.print(' '); // print time since test started
			Serial.print(strainV); Serial.print(' '); // print strain
			Serial.print(pressure); Serial.print(' '); // print pressure
			Serial.print(myservo.read()); Serial.print(' '); // print serial position
			Serial.print(done);
			Serial.println(']');  // Terminator statement
	}
}

