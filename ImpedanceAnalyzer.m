% Impedance Analyzer Class Delcaration
classdef ImpedanceAnalyzer < handle
properties
    visaObj;
end
methods
    function obj = ImpedanceAnalyzer(varargin)
        switch nargin 
            case 0
                %Case for Testing without setting up impednace analyzer
                obj.visaObj = 1;
            case 1
                try
                    obj.visaObj = visa('agilent',varargin{1});
                    obj.visaObj.InputBufferSize = 100000;
                    obj.visaObj.Timeout = 600;
                    obj.visaObj.ByteOrder = 'littleEndian';
                    fopen(obj.visaObj);
                catch
                    error('Couldn''t open VISA connection. Please enter another visa address\n');
                end
            otherwise
                error('Unexpected Number of Inputs')
        end
    end
    function obj = setVisa(obj,visaObject)
        obj.visaObj = visaObject;
    end
    
    %----------- Private Parameter Functions -----------%
    function setTextParameter(obj,command,validValues,value)
        for i = 1:3
            if(~strcmp(query(obj.visaObj,sprintf('%s?',command)),sprintf('%s\n',value)))
                switch value
                    case validValues
                        fprintf(obj.visaObj,sprintf('%s %s',command,value));
                    otherwise
                        fprintf('Invalid Parameter: ''%s''\n',value);
                        return;
                end
            else
                return
            end     
        end
        fprintf('Could Not Set %s %s\n',command,value);
    end
    function setNumParameter(obj,command,value,min,max,inc)
        for i=1:3
            if (str2num(query(obj.visaObj,sprintf('%s?',command)))~= value) %#ok<*ST2NM>
                if (rem(value,inc)==0 && value>=min && value<=max) 
                    fprintf(obj.visaObj,sprintf('%s %s',command, num2str(value)));
                else
                    fprintf('Invalid Number\nNumber must be greater than %d and less than %d.\nIt also must be divisible by %d\n',min,max,inc);
                    return;
                end
            else
                return;
            end    
        end
        disp('Could Not Set %s %s\n',command,value);
    end
    
    
    %----------- OSC Functions -----------%
    function setOSCMode(obj,type)
        command = ':SOUR1:MODE';
        validValues = {'VOLT','CURR'};
        obj.setTextParameter(command,validValues,type); 
    end
    function setOSCCurrent(obj, value) 
        if ~strcmp(query(obj.visaObj,':SOUR1:MODE?'),sprintf('%s\n','CURR'))
            h = questdlg({'OSC Mode is not Current';'Would you like to change the mode to Current?'},'', 'Yes','No','Yes');
            switch h 
                case 'Yes'
                    obj.setOSCMode('CURR');
                case 'No'
                    return
            end
        end
        command = ':SOUR1:CURR';
        min = 200e-6;
        max = 20e-3;
        inc = 0.00002;
        obj.setNumParameter(command,value,min,max,inc);
    end
    function setOSCVoltage(obj, value) 
        if ~strcmp(query(obj.visaObj,':SOUR1:MODE?'),sprintf('%s\n','VOLT'))
            h = questdlg({'OSC Mode is not Voltage';'Would you like to change the mode to Voltage?'},'', 'Yes','No','Yes');
            switch h 
                case 'Yes'
                    obj.setOSCMode('VOLT');
                case 'No'
                    return
            end
        end
        command = ':SOUR1:VOLT';
        min = 0.005;
        max = 1;
        inc = 0.001;
        obj.setNumParameter(command,value,min,max,inc);
    end
    
    %----------- Adapter Functions -----------%
    function setAdapter(obj,type)
    % SETADAPTER Sets the Adapter Type for the Impedance Analyzer
    % obj = SETADAPTER(str); 
    % str is a string containing on of the following values:
    % 'NONE','E4M1','E4M2','E4A7','E4AE7','E4PR','E4PE'
    % 
        command = ':SENS:ADAP:TYPE';
        validValues = {'NONE','E4M1','E4M2','E4A7','E4AE7','E4PR','E4PE'};
        obj.setTextParameter(command,validValues,type);
    end
    function setFixtureType(obj,type)
        command = ':SENS1:FIXT:SEL';
        validValues = {'ARB','FIXT16089'};
        obj.setTextParameter(command,validValues,type);
    end
    
    %----------- Sweep Functions -----------%
    function setSweepType(obj,type)
        command = ':SENS1:SWE:TYPE';
        validValues = {'LIN','LOG'};
        obj.setTextParameter(command,validValues,type);
    end
    function setStartFrequency(obj,value)
        command = ':SENS1:FREQ:STAR';
        min = 20;
        max = 120000000;
        inc = 1;
        obj.setNumParameter(command,value,min,max,inc);
    end
    function setStopFrequency(obj,value)
        command = ':SENS1:FREQ:STOP';
        min = 20;
        max = 120000000;
        inc = 1;
        obj.setNumParameter(command,value,min,max,inc);
    end
    function setNumberOfPoints(obj,value)
        command = ':SENS1:SWE:POIN';
        min = 2;
        max = 1601;
        inc = 1;
        obj.setNumParameter(command,value,min,max,inc);
    end
    function setAccuracy(obj,type)
        command = ':SENS1:APER';
        validValues = {1,2,3,4,5};
        obj.setTextParameter(command,validValues,type);
    end
    %----------- Averaging Functions -----------%
    function setAveraging(obj,type)
        command = ':CALC1:AVER';
        validValues = {'ON','OFF'};
        obj.setTextParameter(command,validValues,type);
    end
    function setAveragingCount(obj,value)
        command = ':CACL1:AVER:COUN';
        min = 1;
        max = 999;
        inc = 1;
        obj.setNumParameter(command,value,min,max,inc);
    end
   
    %----------- Calibration Functions -----------%
    function setCompensationPoint(obj,type)
        command = ':SENS1:CORR:COLL:FPO';
        validValues = {'FIX','USER'};
        obj.setTextParameter(command,validValues,type);
    end
    %Need a function for each part of calibartion OPEN SHORT LOAD
    function calibrate(obj)
        h = questdlg('Connect Short Circuit and click Ok when ready','', 'OK','Exit','OK');
        switch h 
            case 'Exit'
                return
        end
        fprintf(obj.visaObj,':SENS1:CORR2:COLL:ACQ:SHOR');
        obj.waitForComplete();
        obj.sound();
        %Preform OPEN Circuit Calibration 
        h = questdlg('Connect Open Circuit and click Ok when ready','', 'OK','Exit','OK');
        switch h 
            case 'Exit'
                return
        end
        fprintf(obj.visaObj,':SENS1:CORR2:COLL:ACQ:OPEN');
        obj.waitForComplete();
        obj.sound();
        %Preform LOAD Circuit Calibration 
        h = questdlg('Connect Load Circuit and click Ok when ready','', 'OK','Exit','OK');
        switch h 
            case 'Exit'
                return
        end
        fprintf(obj.visaObj,':SENS1:CORR2:COLL:ACQ:LOAD');
        obj.waitForComplete();
        obj.sound();
    end
    
    
    %Trace Functions Need work%
    function setTrace1(obj,type,varargin)
        switch(length(varargin))
            case 0
                obj.setTrace(1,1,type);
            case 1 
                if (varargin{1}>=1 && varargin{1}<=4 && mod(varargin{1},1)==0)
                    obj.setTrace(varargin{1},1,type);
                else
                    error('Invalid Channel');
                end
            otherwise
                error('Invalid Number of Arguments');
        end
    end
    function setTrace2(obj,type,varargin)
        switch(length(varargin))
            case 0
                obj.setTrace(1,2,type);
            case 1 
                if (varargin{1}>=1 && varargin{1}<=4 && mod(varargin{1},1)==0)
                    obj.setTrace(varargin{1},2,type);
                else
                    error('Invalid Channel');
                end
            otherwise
                error('Invalid Number of Arguments');
        end
    end
    function setTrace3(obj,type,varargin)
        switch(length(varargin))
            case 0
                obj.setTrace(1,3,type);
            case 1 
                if (varargin{1}>=1 && varargin{1}<=4 && mod(varargin{1},1)==0)
                    obj.setTrace(varargin{1},3,type);
                else
                    error('Invalid Channel');
                end
            otherwise
                error('Invalid Number of Arguments');
        end
    end
    function setTrace4(obj,type,varargin)
        switch(length(varargin))
            case 0
                obj.setTrace(1,4,type);
            case 1 
                if (varargin{1}>=1 && varargin{1}<=4 && mod(varargin{1},1)==0)
                    obj.setTrace(varargin{1},4,type);
                else
                    error('Invalid Channel');
                end
            otherwise
                error('Invalid Number of Arguments');
        end
    end
    
    function setTrace(obj,type,trace,chan)
        command = sprintf(':CALC%d:PAR%d:DEF',chan,trace);
        validValues = {'Z','Y','R','X','G','B','LS','LP','CS','CP','RS','RP','Q','D','TZ','TY','VAC','IAC','VDC','IDC','IMP','ADM'};
        obj.setTextParameter(command,validValues,type);
    end
    
    function setTriggerSource(obj,type)
        command = ':TRIG:SOUR';
        validValues = {'INT','EXT','MAN','BUS'};
        obj.setTextParameter(command,validValues,type);
    end
    function triggerSweep(obj)
        fprintf(obj.visaObj,'*TRG');
    end
    function abortSweep(obj)
        fprintf(obj.visaObj,':ABOR');
    end
    function sound(obj)
        fprintf(obj.visaObj,':SYST:BEEP:COMP:IMM');
    end
    %OPC function
    function waitForComplete(obj)
        operationComplete = str2double(query(obj.visaObj,'*OPC?'));
        while ~operationComplete
            operationComplete = str2double(query(obj.visaObj,'*OPC?'));
        end
        clear operationComplete;
    end
   
    
    function data = getData(obj,type,chan)
        obj.waitForComplete();
        for i=1:4
            if strcmp(query(obj.visaObj,sprintf(':CALC%d:PAR%d:DEF?',chan,i)), sprintf('%s\n',type))
                fprintf(obj.visaObj,sprintf(':CALC%d:PAR%d:SEL',chan,i));
                strData =  query(obj.visaObj,':CALC1:DATA:FDAT?');
                numData = str2num(strData);
                data = numData(1:2:end);%Gets Every Other Term, because ZA outputs a zero in between each data point
                return;
            end
        end
        fprintf('%s was not found as a Trace Parameter on Channel %d',type,chan);
    end
    function [real,imag,freq]= getRXF(obj,varargin)
        switch lenght(varargin)
            case 0
                real = obj.getData('R',1);
                imag = obj.getData('X',1);
                freq = obj.getF();
            case 1
                real = obj.getData('R',varargin{1});
                imag = obj.getData('X',varargin{1});
                freq = obj.getF();%Change getF to accomadate for each channel
        end
    end
    function [z,theta,freq] = getZTF(obj,varargin)
        switch lenght(varargin)
            case 0
                z = obj.getData('Z',1);
                theta = obj.getData('TZ',1);
                freq = obj.getF();
            case 1
                z = obj.getData('Z',varargin{1});
                theta = obj.getData('TZ',varargin{1});
                freq = obj.getF();%Change getF to accomadate for each channel
        end
    end
    
    function data = getR(obj,varargin)
        switch lenght(varargin)
            case 0
                data = obj.getData('R',1);
            case 1
                if obj.isValidChannel(varargin{1})
                    data = obj.getData('R',varargin{1});
                else
                    error('Invalid Channel');
                end
        end
    end
    function data = getX(obj,varargin)
        switch lenght(varargin)
            case 0
                data = obj.getData('X',1);
            case 1
                if obj.isValidChannel(varargin{1})
                    data = obj.getData('X',varargin{1});
                else
                    error('Invalid Channel');
                end
        end
    end
    function data = getZ(obj,varargin)
        switch lenght(varargin)
            case 0
                data = obj.getData('Z',1);
            case 1
                if obj.isValidChannel(varargin{1})
                    data = obj.getData('Z',varargin{1});
                else
                    error('Invalid Channel');
                end
        end
    end
    function data = getT(obj,varargin)
        switch lenght(varargin)
            case 0
                data = obj.getData('TZ',1);
            case 1
                if obj.isValidChannel(varargin{1})
                    data = obj.getData('TZ',varargin{1});
                else
                    error('Invalid Channel');
                end
                
        end
    end
    
    function data = getF(obj,varargin)
        switch lenght(varargin)
            case 0
                fStr =  query(obj.visaObj,':SENS1:FREQ:DATA?');
            case 1
                if obj.isValidChannel(varargin{1})
                    fStr =  query(obj.visaObj,sprintf(':SENS%d:FREQ:DATA?',varargin{1}));
                else
                    error('Invalid Channel');
                end
                
        end
        data = str2num(fStr);
    end
    
    function bool = isValidChannel(chan)
        bool = (chan>=1 && chan<=4 && mod(chan,1)==0);       
    end
    
    
    function close(obj)
        fclose(obj.visaObj);
    end
    function delete(obj)
            disp('Closed');
            obj.close();
    end
    
   end
end