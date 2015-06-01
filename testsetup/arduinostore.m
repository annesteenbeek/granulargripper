function arduinostore(time, strain,pressure, servopos,...
    zerovolt, calvolt, calweight, triggerpressure, grainsize)
    
    % load previous data
    load('researchdata.mat');
    
    Time = [Time, time];
    Strain = [Strain, strain];
    Pressure = [Pressure, pressure];
    Servopos = [Servopos, servopos];
    
    % find row in structure for current grain size
    structrow = find([testdata.Grainsize]==grainsize); 
      
    % if this is a new grain size, create new structure row
    if(isempty(structrow))
        structrow = length([testdata.Grainsize])+1;
    end
    
    % get the structure for the results
    measuredata = testdata(structrow).tests;
    
    % get the row on which to add new results
    measurerow = length([measuredata.resulttable])+1;
    
    measuredata(measurerow).resulttable = table(Time, Strain, Pressure, Servopos);
    measuredata(measurerow).calibrate = [zerovolt, calvolt, calweight];
    measuredata(measurerow).Triggerpressure = triggerpressure;
    measuredata(measurerow).testtime = now;
    
    % store the results in
    testdata(structrow).Grainsize = grainsize;
    testdata(structrow).tests = measuredata;
    
    % save the data
    save('researchdata.mat');
end