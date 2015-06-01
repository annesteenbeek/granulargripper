clear all
close all
clc
% close and clear all instruments
delete(instrfind); 

% open serial connection
Serial = serial('/dev/ttyS101');
Serial.Terminator = 'CR/LF';
fopen(Serial);

% Calibration values
zerovolt = 0; % voltage when 0kg is applied
calvolt = 0; % voltage when weight has been applied
calweight = 0; % weight that has been applied

grainsize = 0; % set the current grain size
triggerpressure = 0; % air pressure at which the servo should start

i=0;
serialdata = zeros(10000,8); % create empty object for speed
while true
    
    % start storing data when arduino is sending
    while Serial.BytesAvailable > 0
        
        newline = fgetl(Serial);
        if newline(1) == '[' % if newline is array, store it
            i=i+1;
            serialdata(i,:) = str2num(newline);
        else % else interpret serial line as error
            warning(newline);
        end
        
        % when done signal is received, store the data in structure
        if serialdata(i,5) == 1
            load('testdata.mat', 'testdata'); 
            Time = serialdata(1:i,1);
            Strain = serialdata(1:i,2);
            Pressure = serialdata(1:i,3);
            Servopos = serialdata(1:i,4);
            
            data = table(Time, Strain, Pressure, Servopos);
               
            % find row in structure for current grain size
            structrow = find([testdata.Grainsize]==grainsize); 

            % if this is a new grain size, create new structure row
            if(isempty(structrow))
                structrow = length([testdata.Grainsize])+1;
            end
            
            testdata(structrow).Grainsize = grainsize;
            % if there is no data in the substruct yet, place it
            try
                testdata(structrow).tests(end+1).testtime = now;
            catch exception
                testdata(structrow).tests(1).testtime = now;
                disp('created initial structure row');
            end
            
            testdata(structrow).tests(end).data = data;
            save('testdata.mat', 'testdata');
            disp('Stored new data');
            serialdata = serialdata == 0; % empty serial object
            i=0;
        end
    end
end