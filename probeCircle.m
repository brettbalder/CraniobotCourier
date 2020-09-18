function [commandArray] = probeCircle(circDia,X,Y,Z,probeSpeed)
    % Objective:  This function probes the skull in a circle centered on 
    % the input coordinates. A text file with gcode 
    % is then output which may then be sent to the Craniobot. The output file 
    % contains skull coordinates in the work coordainate system, not machine CS.
    %
    % Variables:
    % circRadius    Radius of disired plug 
    % X,Y,Z         Stereotax coordinates of desired plug
    % probeSpeed    Feedrate of probe towards skull (units/min)
    % tool          number of tool in tool table

    % Stereo2Robot transformation is the transformation from stereotax space to
    % machine space
    
    Stereo2Robot = [1,0,0,0;...
                    0,1,0,0;...
                    0,0,1,0;...
                    0,0,0,1];
    % Create the center position variable in robot space
    centerPos = Stereo2Robot*[X;Y;Z;1];

    % Choose resolution of points.
    numberPoints = 10;
    resolutionCirc = 2*pi/numberPoints;
    theta = 0:resolutionCirc:2*pi-resolutionCirc;

    % Create circle projection
    Xproj = centerPos(1) + circDia*cos(theta)/2;
    Yproj = centerPos(2) + circDia*sin(theta)/2;
    offsetVal = 3;
    Zmin = -90; %used to define where the probe should home towards
    
    % Find a safe spot above the skull to home to
    if(Z+offsetVal > 0)
        Zoffset = 0;
    else
        Zoffset = centerPos(3) + offsetVal;
    end

    % create .txt file to store path
    fileID = fopen('probePath.txt','w');
    
    % make header commands
    fprintf(fileID,'%s\n', strcat("N1 G90; (set to absolute coordinates motion)"));
    fprintf(fileID,'%s\n', "N2 G21; (set to millimeters)");
    fprintf(fileID,'%s\n', strcat("N3 G0 X",num2str(Xproj(1)),...
            " Y",num2str(Yproj(1)),...
            " Z",num2str(offsetVal)));
    
    % Loop through theta by 1 step
    ln = 3; % line number
    for ii = 1:numberPoints
    % Move to next X,Y probing point
        ln = ln+1;
        probePos = [Xproj(ii),Yproj(ii),Zoffset];
        fprintf(fileID,'%s\n', strcat("N",num2str(ln),...
            " G90 G0 X",num2str(probePos(1)),...
            " Y",num2str(probePos(2))));
        ln = ln+1;
    % Probe Command
        fprintf(fileID,'%s\n',strcat("N",num2str(ln),...
            " G38.2 Z",num2str(Zmin),...
            " F",num2str(probeSpeed)));
        ln = ln+1;
    % Retract by offset amount
        fprintf(fileID,'%s\n',strcat("N", num2str(ln),...
            " G91 G0 Z",num2str(offsetVal)));
    end
    
    % make footer commands
    fprintf(fileID,'%s\n',strcat("N", num2str(ln+1),...
        " M2; (Program Complete)"));
    fclose(fileID);
    
end

