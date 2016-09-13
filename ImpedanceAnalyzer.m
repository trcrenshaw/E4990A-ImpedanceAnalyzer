% Impedance Analyzer Class Delcaration
classdef ImpedanceAnalyzer 
   properties
   %Need property for each setting that can be changed
    visaObj;
   end
   methods
   %Need Constructor that Sets up connection given a VISA address (Try to
   %open connection. If no connection available, propmt for address again
    function obj = ImpedanceAnalyzer(varargin)
            switch nargin 
                case 0
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
    
    %*********** Functions to Set Impedance Analyzer Settings ******** %
    
    function obj = setOSCMode(obj,type)
        while (~strcmp(query(obj.visaObj,':SOUR1:MODE?'),sprintf('%s\n',type)))
            switch type
                case {'VOLT','CURR'}
                    fprintf(obj.visaObj,[':SOUR1:MODE ' type]);
                otherwise
                    disp('Invalid OSC Mode. Please Try Again');
                    return;
            end
       end
    end
    function obj = setOSCCurrent(obj, value)
        if ~strcmp(query(obj.visaObj,':SOUR1:MODE?'),sprintf('%s\n','CURR'))
            h = questdlg({'OSC Mode is not Current';'Would you like to change the mode to Current?'},'', 'Yes','No','Yes');
            switch h 
                case 'Yes'
                    obj.setOSCMode('CURR');
                case 'No'
                    return
            end
        end
        while (str2num(query(obj.visaObj,':SOUR1:CURR?'))~= value)
            if (rem(value,0.00002)==0 && value>=200e-6 && value<=20e-3) 
                fprintf(obj.visaObj,[':SOUR1:CURR ' num2str(value)]);
            else
                disp('Invalid Trace Type. Please Try Again');
                return;
            end
        end
    end
    function obj = setOSCVoltage(obj, value)
        if ~strcmp(query(obj.visaObj,':SOUR1:MODE?'),sprintf('%s\n','VOLT'))
            h = questdlg({'OSC Mode is not Voltage';'Would you like to change the mode to Voltage?'},'', 'Yes','No','Yes');
            switch h 
                case 'Yes'
                    obj.setOSCMode('VOLT');
                case 'No'
                    return
            end
        end
        while (str2num(query(obj.visaObj,':SOUR1:VOLT?'))~= value)
            if (rem(value,0.001)==0 && value>=0.005 && value<=1) 
                fprintf(obj.visaObj,[':SOUR1:VOLT ' num2str(value)]);
            else
                disp('Invalid Trace Type. Please Try Again');
                return;
            end
        end    
    end
    
    function obj = setAdapter(obj,type)
    % SETADAPTER Sets the Adapter Type for the Impedance Analyzer
    % obj = SETADAPTER(str); 
    % str is a string containing on of the following values:
    % 'NONE','E4M1','E4M2','E4A7','E4AE7','E4PR','E4PE'
    % 
       while (~strcmp(query(obj.visaObj,':SENS:ADAP:TYPE?'),sprintf('%s\n',type)))
            switch type
                case {'NONE','E4M1','E4M2','E4A7','E4AE7','E4PR','E4PE'}
                    fprintf(obj.visaObj,[':SENS:ADAP:TYPE ' type]);
                otherwise
                    disp('Invalid Adaptor Type. Please Try Again');
                    return;
            end
       end
    end
    
    function obj = setTrace1(obj,type)
%         switch(nargin)
%             case 1
%                 obj.setTrace(1,1,varargin{1});
%             case 2 
%                 if varargin{2}>=1 && varargin{2}>=1<=4 && isinteger(varargin{2})
%                     obj.setTrace(1,varargin{2},varargin{1});
%                 else
%                     error('Invalid Channel');
%                 end
%             otherwise
%                 error('Invalid Number of Arguments');
%         end
        
        while (~strcmp(query(obj.visaObj,':CALC1:PAR1:DEF?'),sprintf('%s\n',type)))
            switch type
                case {'Z','Y','R','X','G','B','LS','LP','CS','CP','RS','RP','Q','D','TZ','TY','VAC','IAC','VDC','IDC','IMP','ADM'}
                    fprintf(obj.visaObj,[':CALC1:PAR1:DEF ' type]);
                otherwise
                    disp('Invalid Trace Type. Please Try Again');
                    return;
            end
        end
    end
    function obj = setTrace2(obj,type)
%        switch(nargin)
%             case 1
%                 obj.setTrace(1,2,varargin{1});
%             case 2 
%                 if varargin{2}>=1 && varargin{2}>=1<=4 && isinteger(varargin{2})
%                     obj.setTrace(1,varargin{2},varargin{1});
%                 else
%                     error('Invalid Channel');
%                 end
%             otherwise
%                 error('Invalid Number of Arguments');
%         end
        while (~strcmp(query(obj.visaObj,':CALC1:PAR2:DEF?'), sprintf('%s\n',type)))
            switch type
                case {'Z','Y','R','X','G','B','LS','LP','CS','CP','RS','RP','Q','D','TZ','TY','VAC','IAC','VDC','IDC','IMP','ADM'}
                    fprintf(obj.visaObj,[':CALC1:PAR2:DEF ' type]);
                otherwise
                    disp('Invalid Trace Type. Please Try Again');
                    return;
            end
        end
    end
    function obj = setTrace3(obj,varargin)
       switch(nargin)
            case 1
                obj.setTrace(1,3,varargin{1});
            case 2 
                if varargin{2}>=1 && varargin{2}>=1<=4 && isinteger(varargin{2})
                    obj.setTrace(1,varargin{2},varargin{1});
                else
                    error('Invalid Channel');
                end
            otherwise
                error('Invalid Number of Arguments');
        end
    end
    function obj = setTrace4(obj,varargin)
        switch(nargin)
            case 1
                obj.setTrace(1,1,varargin{1});
            case 2 
                if varargin{2}>=1 && varargin{2}>=1<=4 && isinteger(varargin{2})
                    obj.setTrace(1,varargin{2},varargin{1});
                else
                    error('Invalid Channel');
                end
            otherwise
                error('Invalid Number of Arguments');
        end
    end
    function obj = setTrace(obj,chan,trace,type)
        while (~strcmp(query(obj.visaObj,sprintf(':CALC%d:PAR%d:DEF?',chan,trace)), sprintf('%s\n',type)))
            switch type
                case {'Z','Y','R','X','G','B','LS','LP','CS','CP','RS','RP','Q','D','TZ','TY','VAC','IAC','VDC','IDC','IMP','ADM'}
                    fprintf(obj.visaObj,[sprintf(':CALC%d:PAR%d:DEF?',chan,trace) type]);
                otherwise
                    disp('Invalid Trace Type. Please Try Again');
                    return;
            end
        end
    end
    
    function obj = setAccuracy(obj,type)
        while (str2num(query(obj.visaObj,':SENS1:APER?'))~=type)
            switch type
                case {1,2,3,4,5}
                    fprintf(obj.visaObj,[':SENS1:APER ' num2str(type)]);
                otherwise
                    disp('Invalid Trace Type. Please Try Again');
                    return;
            end
        end
    end
    function obj = setSweepType(obj,type)
        while (~strcmp(query(obj.visaObj,':SENS1:SWE:TYPE?'), sprintf('%s\n',type)))
            switch type
                case {'LIN','LOG'}
                    fprintf(obj.visaObj,[':SENS1:SWE:TYPE ' type]);
                otherwise
                    disp('Invalid Trace Type. Please Try Again');
                    return;
            end
        end
    end
    
    function obj = setStartFrequency(obj,type)
        while (str2num(query(obj.visaObj,':SENS1:FREQ:STAR?'))~= type)
            if (rem(type,1)==0 && type>=20 && type<=120000000) 
                fprintf(obj.visaObj,[':SENS1:FREQ:STAR ' num2str(type)]);
            else
                disp('Invalid Trace Type. Please Try Again');
                return;
            end
        end
    end
    function obj = setStopFrequency(obj,type)
        while (str2num(query(obj.visaObj,':SENS1:FREQ:STOP?'))~= type)
            if (rem(type,1)==0 && type>=20 && type<=120000000) 
                fprintf(obj.visaObj,[':SENS1:FREQ:STOP ' num2str(type)]);
            else
                disp('Invalid Trace Type. Please Try Again');
                return;
            end
        end
    end
    function obj = setNumberOfPoints(obj,type)
        while (str2num(query(obj.visaObj,':SENS1:SWE:POIN?'))~=type)
            if (rem(type,1)==0 && type>=2 && type<=1601) 
                fprintf(obj.visaObj,['SENS1:SWE:POIN ' num2str(type)]);
            else
                disp('Invalid Trace Type. Please Try Again');
                return;
            end
        end
    end
    function obj = setFixtureType(obj,type)
        while (~strcmp(query(obj.visaObj,':SENS1:FIXT:SEL?'), sprintf('%s\n',type)))
            switch type
                case {'ARB','FIXT16089'}
                    fprintf(obj.visaObj,[':SENS1:FIXT:SEL ' type]);
                otherwise
                    disp('Invalid Trace Type. Please Try Again');
                    return;
            end
        end
    end
    function obj = setCompensationPoint(obj,type)
        while (~strcmp(query(obj.visaObj,':SENS1:CORR:COLL:FPO?'),sprintf('%s\n',type)))
            switch type
                case {'FIX','USER'}
                    fprintf(obj.visaObj,[':SENS1:CORR:COLL:FPO ' type]);
                otherwise
                    disp('Invalid Trace Type. Please Try Again');
                    return;
            end
        end
    end
    function obj = setTriggerSource(obj,type)
        while (~strcmp(query(obj.visaObj,':TRIG:SOUR?'),sprintf('%s\n',type)))
            switch type
                case {'INT','EXT','MAN','BUS'}
                    fprintf(obj.visaObj,[':TRIG:SOUR ' type]);
                otherwise
                    disp('Invalid Trace Type. Please Try Again');
                    return;
            end
        end
    end
    function obj = triggerSweep(obj)
        fprintf(obj.visaObj,':TRIG:SING');
        %obj.waitForComplete();
        %obj.sound();
        
    end
    function obj = abortSweep(obj)
        fprintf(obj.visaObj,':ABOR');
    end
    function obj = sound(obj)
        fprintf(obj.visaObj,':SYST:BEEP:COMP:IMM');
    end
    
    %need a calibrate fixture function 
    function obj = calibrate(obj)
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
    %OPC function
    function obj = waitForComplete(obj)
        operationComplete = str2double(query(obj.visaObj,'*OPC?'));
        while ~operationComplete
            operationComplete = str2double(query(obj.visaObj,'*OPC?'));
        end
        clear operationComplete;
        obj.sound();
    end
   
    %Get Data 2 formats('rx' or 'zt') returns [r,x] or [z,t]
    function data = getR(obj)
        obj.waitForComplete();
        if strcmp(query(obj.visaObj,':CALC1:PAR1:DEF?'), sprintf('R\n'))
            fprintf(obj.visaObj,':CALC1:PAR1:SEL');
        elseif strcmp(query(obj.visaObj,':CALC1:PAR2:DEF?'), sprintf('R\n'))
            fprintf(obj.visaObj,':CALC1:PAR2:SEL');
        else
            disp('R is not one of the traces');
            return;
        end
        rStr =  query(obj.visaObj,':CALC1:DATA:FDAT?');
        rNum = str2num(rStr);
        data = rNum(1:2:end);
    end
    function data = getX(obj)
        obj.waitForComplete();
        if strcmp(query(obj.visaObj,':CALC1:PAR1:DEF?'), sprintf('X\n'))
            fprintf(obj.visaObj,':CALC1:PAR1:SEL');
        elseif strcmp(query(obj.visaObj,':CALC1:PAR2:DEF?'), sprintf('X\n'))
            fprintf(obj.visaObj,':CALC1:PAR2:SEL');
        else
            disp('X is not one of the traces');
            return;
        end
        xStr =  query(obj.visaObj,':CALC1:DATA:FDAT?');
        xNum = str2num(xStr);
        data = xNum(1:2:end);
    end
    function data = getZ(obj)
        obj.waitForComplete();
        if strcmp(query(obj.visaObj,':CALC1:PAR1:DEF?'), sprintf('Z\n'))
            fprintf(obj.visaObj,':CALC1:PAR1:SEL');
        elseif strcmp(query(obj.visaObj,':CALC1:PAR2:DEF?'), sprintf('Z\n'))
            fprintf(obj.visaObj,':CALC1:PAR2:SEL');
        else
            disp('Z is not one of the traces');
            return;
        end
        zStr =  query(obj.visaObj,':CALC1:DATA:FDAT?');
        zNum = str2num(zStr);
        data = zNum(1:2:end);
    end
    function data = getT(obj)
        obj.waitForComplete();
        if strcmp(query(obj.visaObj,':CALC1:PAR1:DEF?'), sprintf('TZ\n'))
            fprintf(obj.visaObj,':CALC1:PAR1:SEL');
        elseif strcmp(query(obj.visaObj,':CALC1:PAR2:DEF?'), sprintf('TZ\n'))
            fprintf(obj.visaObj,':CALC1:PAR2:SEL');
        else
            disp('T is not one of the traces');
            return;
        end
        tStr =  query(obj.visaObj,':CALC1:DATA:FDAT?');
        tNum = str2num(tStr);
        data = tNum(1:2:end);
    end
    
    function data = getF(obj)
        fStr =  query(obj.visaObj,':SENS1:FREQ:DATA?');
        data = str2num(fStr);
    end
    function obj = close(obj)
        fclose(obj.visaObj);
    end
   end
end