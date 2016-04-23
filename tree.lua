gpio.mode(PIN_HEAT, gpio.OUTPUT);
gpio.write(PIN_HEAT, gpio.HIGH);
gpio.mode(PIN_VANNE, gpio.OUTPUT);
gpio.write(PIN_VANNE, gpio.HIGH);
gpio.mode(PIN_PUMP_PURGE, gpio.OUTPUT);
gpio.write(PIN_PUMP_PURGE, gpio.HIGH);
gpio.mode(PIN_PUMP_CYCLE, gpio.OUTPUT);
gpio.write(PIN_PUMP_CYCLE, gpio.HIGH);
gpio.mode(PIN_THERMOSTAT, gpio.INPUT, gpio.PULLUP);
gpio.mode(PIN_PORTE, gpio.INPUT, gpio.PULLUP);

function	heat_on()
	gpio.write(PIN_HEAT, gpio.LOW);
	debug_serial(1, HEAT);
end
function	heat_off()
	gpio.write(PIN_HEAT, gpio.HIGH);
	debug_serial(0, HEAT);
end

function	cycle_on()
	gpio.write(PIN_PUMP_CYCLE, gpio.LOW);
	debug_serial(1, CYCLE);
end
function	cycle_off()
	gpio.write(PIN_PUMP_CYCLE, gpio.HIGH);
	debug_serial(0, CYCLE);
end

function	purge_on()
	gpio.write(PIN_PUMP_PURGE, gpio.LOW);
	debug_serial(1, PURGE);
end
function	purge_off()
	gpio.write(PIN_PUMP_PURGE, gpio.HIGH);
	debug_serial(0, PURGE);
end

function	check_level()
	int		retour_read = 0;
	retour_read = analogRead(PIN_LEVEL);
	if(retour_read > 100)
	then
		debug_serial(1, LEVEL);
		return true;
	end
else

	debug_serial(0, LEVEL);
	return false;
end
end

function	check_thermostat()
	if(digitalRead(PIN_THERMOSTAT))
	then
		debug_serial(1, LEVEL);
		return true;
	end
	debug_serial(0, LEVEL);
	return false;
end

function	debug_serial(boolean value, int flag)
	static boolean		heat	= 0;
	static boolean		thermo	= 0;
	static boolean		cycle	= 0;
	static boolean		vanne	= 0;
	static boolean		purge	= 0;
	static boolean		level	= 0;
	static boolean		porte	= 0;
	boolean				print	= 0;
	unsigned long		uptime	= 0;
	unsigned long		uptime2	= 0;

	if(flag == HEAT && heat != value)
	then
		heat = value;
		print = 1;
	end
else if(flag == THERMO && thermo != value)
	then
		thermo = value;
		print = 1;
	end
else if(flag == CYCLE && cycle != value)
	then
		cycle = value;
		print = 1;
	end
else if(flag == VANNE && vanne != value)
	then
		vanne = value;
		print = 1;
	end
else if(flag == PURGE && purge != value)
	then
		purge = value;
		print = 1;
	end
else if(flag == LEVEL && level != value)
	then
		level = value;
		print = 1;
	end
else if(flag == PORTE && porte != value)
	then
		porte = value;
		print = 1;
	end

	if(print)
	then
		Serial.println("\n\n");
		Serial.print("Chauffe :\t");
		Serial.println(heat ? "TRUE" : "FALSE");
		Serial.print("Thermostat :\t");
		Serial.println(thermo ? "TRUE" : "FALSE");
		Serial.print("Cycle :\t\t");
		Serial.println(cycle ? "TRUE" : "FALSE");
		Serial.print("Vanne :\t\t");
		Serial.println(vanne ? "TRUE" : "FALSE");
		Serial.print("Purge :\t\t");
		Serial.println(purge ? "TRUE" : "FALSE");
		Serial.print("Porte :\t\t");
		Serial.println(porte ? "TRUE" : "FALSE");
		Serial.print("Level :\t\t");
		Serial.println(level ? "TRUE" : "FALSE");
		Serial.print("\n");
		Serial.print("Uptime : ");
		uptime2 = millis();
		uptime = uptime2 / 1000;
		Serial.print(uptime / 60);
		Serial.print(" minutes ");
		Serial.print(uptime % 60);
		Serial.print((uptime % 60) > 1 ? " secondes " : " seconde ");
		Serial.print(uptime2 % 1000);
		Serial.println(" ms");
	end
end

function	fillwater()
	while(!check_level())

	gpio.write(PIN_VANNE, gpio.LOW);
	debug_serial(1, VANNE);
end
gpio.write(PIN_VANNE, gpio.HIGH);
debug_serial(0, VANNE);
end

function	chauffe()
	if(check_thermostat())
	then
		heat_on();
		cycle_on();
	end
else

	heat_off();

	if(check_level())
	then
		cycle_on();
	end
else

	cycle_off();
end
end
end

long	check_porte()
unsigned long enter = millis();
if(digitalRead(PIN_PORTE))
then
	while(digitalRead(PIN_PORTE))

	gpio.write(PIN_HEAT, gpio.HIGH);
	debug_serial(0, HEAT);
	gpio.write(PIN_PUMP_CYCLE, gpio.HIGH);
	debug_serial(0, CYCLE);
	gpio.write(PIN_PUMP_PURGE, gpio.HIGH);
	debug_serial(0, PURGE);
	gpio.write(PIN_VANNE, gpio.HIGH);
	debug_serial(0, VANNE);
	debug_serial(1, PORTE);
end
delay(2000);
debug_serial(0, PORTE);
return (millis() - enter);
end
return (0);
end

function	stop()
	Serial.println("Fini !");
	Serial.println("Fini !");
	Serial.println("Fini !");

	while(1)

	delay(100000);
end
end

function	loop()
	unsigned long	start;
	unsigned long	current;
	unsigned long	duree_lavage = 2400000;
	unsigned long	duree_rincage = 300000;

	fillwater();
	delay(1000);
	start = millis();
	while(1)

	duree_lavage += check_porte();
	chauffe();
	current = millis();
	if(current - start > duree_lavage)
	btheneak;
end
heat_off();
cycle_off();
purge_on();
delay(20000);
purge_off();
while(RINCAGE)

duree_rincage += check_porte();
chauffe();
current = millis();
if(current - start > duree_rincage)
btheneak;
end
if(RINCAGE)
then
	heat_off();
	cycle_off();
	purge_on();
	delay(20000);
	purge_off();
end
stop();
end
