
pin_level = 0;
pin_heat = 8;
pin_vanne = 6;
pin_pump_cycle = 7;
pin_pump_purge = 5;
pin_thermostat = 3;
pin_porte = 2;

gpio.mode(pin_heat, gpio.OUTPUT);
gpio.write(pin_heat, gpio.HIGH);
gpio.mode(pin_vanne, gpio.OUTPUT);
gpio.write(pin_vanne, gpio.HIGH);
gpio.mode(pin_pump_purge, gpio.OUTPUT);
gpio.write(pin_pump_purge, gpio.HIGH);
gpio.mode(pin_pump_cycle, gpio.OUTPUT);
gpio.write(pin_pump_cycle, gpio.HIGH);
gpio.mode(pin_thermostat, gpio.INPUT, gpio.PULLUP);
gpio.mode(pin_porte, gpio.INPUT, gpio.PULLUP);
gpio.mode(pin_level, gpio.INPUT);

function	heat_on()
	gpio.write(pin_heat, gpio.LOW);
end
function	heat_off()
	gpio.write(pin_heat, gpio.HIGH);
end

function	cycle_on()
	gpio.write(pin_pump_cycle, gpio.LOW);
end
function	cycle_off()
	gpio.write(pin_pump_cycle, gpio.HIGH);
end

function	purge_on()
	gpio.write(pin_pump_purge, gpio.LOW);
end
function	purge_off()
	gpio.write(pin_pump_purge, gpio.HIGH);
end

function	check_level()
	if(100 < gpio.read(pin_level))
	then
		return true;
	else
		return false;
	end
end

function	check_thermostat()
	if(gpio.read(pin_thermostat))
	then
		return true;
	end
	return false;
end

function	fillwater()
	while(check_level() == false)
	do
		gpio.write(pin_vanne, gpio.LOW);
	end
	gpio.write(pin_vanne, gpio.HIGH);
end

function	chauffe()
	if(check_thermostat())
	then
		heat_on();
		cycle_on();
	else

		heat_off();

		if(check_level())
		then
			cycle_on();
		else

			cycle_off();
		end
	end
end

function	check_porte()
enter = tmr.now();
if(gpio.read(pin_porte))
then
	while(gpio.read(pin_porte))
	do
		gpio.write(pin_heat, gpio.HIGH);
		gpio.write(pin_pump_cycle, gpio.HIGH);
		gpio.write(pin_pump_purge, gpio.HIGH);
		gpio.write(pin_vanne, gpio.HIGH);
	end
	delay(2000);
	return (millis() - enter);
end
return (0);
end

function	stop()
	Serial.println("Fini !");
	Serial.println("Fini !");
	Serial.println("Fini !");

	while(1)
	do
		delay(100000);
	end
end


wifi.setmode(wifi.STATION)
wifi.sta.config("tabouret","laviolenceduponey")
print(wifi.sta.getip()) -- Dynamic IP Address

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
	conn:on("receive", function(client,request)
		local buf = "";
		local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
		if(method == nil) then
			_, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
		end
		local _GET = {}
		if (vars ~= nil) then
			for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
				_GET[k] = v
			end
		end
		buf = buf.."<body style=\"font-family: Arial;font-size: 14px;\"><center><h1>Lave vaisselle</h1>";
		buf = buf.."<form method=\"get\">";
		buf = buf.."Pass <input name=\"password\" type=\"password\"/><br />";
		buf = buf.."<br>";
		buf = buf.."Différé (heure): <input type=\"number\" name=\"offset\"><br>";
		buf = buf.."<input type=\"radio\" name=\"type\" value=\"eco\" selected> Eco<br>";
		buf = buf.."<input type=\"radio\" name=\"type\" value=\"normal\"> Normal<br>";
		buf = buf.."<input type=\"radio\" name=\"type\" value=\"intense\"> Intense<br>";
		buf = buf.."<input type=\"checkbox\" name=\"prelavage\" value=\"1\"> Prelavage<br>";
		buf = buf.."<input type=\"submit\" value=\"Submit\">";
		buf = buf.."</form>";
		buf = buf.."</center></body>";

		local _on,_off = "",""
		if (_GET.password == "N0rbert") then
			if(_GET.type == "Court") then
				gpio.write(led2, gpio.LOW);
			elseif(_GET.type == "Intense") then
				gpio.write(led1, gpio.LOW);
			elseif(_GET.type == "Intense") then
				gpio.write(led2, gpio.HIGH);
			elseif(_GET.type == "Intense") then
				gpio.write(led2, gpio.LOW);
			end
		end
		client:send(buf);
		client:close();
		collectgarbage();
	end)
end)
