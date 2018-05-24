function [commandArray] = probeCircle(circRadius,X,Y,Z,probeSpeed)
    % X,Y,Z is the estimated position of the desired cut in stereotax space
    % probeSpeed is the search velocity of the Craniobot in mm/min

    % Stereo2Robot transformation is the transformation from stereotax space to
    % robot space
    
    Stereo2Robot = [1,0,0,0;...
                    0,1,0,0;...
                    0,0,1,0;...
                    0,0,0,1];
    % Create the center position variable in robot space
    centerPos = Stereo2Robot*[X;Y;Z;1];

    % Choose resolution of points. Probe 200 points?
    numberPoints = 36;
    resolutionCirc = 2*pi/numberPoints;
    theta = 0:resolutionCirc:2*pi-resolutionCirc;

    % Create circle projection
    Xproj = X + circRadius*cos(theta);
    Yproj = Y + circRadius*sin(theta);
    offsetVal = 20;
    if(Z>-20)
        offsetVal = Z + offsetVal;
    end
        
    Zoffset = Z + offsetVal; % Find a safe spot above the skull to home to

    %Zoffest(find(Zoffset>0)) = 0;
    % create .txt file to store path
    fileID = fopen('probePath.txt','w');
    
    % make header commands
    fprintf(fileID,'%s\n', "G90; (set to absolute coordinates)");
    fprintf(fileID,'%s\n', "G21; (set to millimeters)");
    fprintf(fileID,'%s\n', strcat("G0 X",num2str(Xproj(1)),...
            " Y",num2str(Yproj(1)),...
            " Z0"));
    
    % Loop through theta by 1 step
    for ii = 1:numberPoints
    % Move to current X, Y, probing point
        probePos = [Xproj(ii),Yproj(ii),Zoffset];
        fprintf(fileID,'%s\n', strcat("G0 X",num2str(probePos(1)),...
            " Y",num2str(probePos(2)),...
            " Z",num2str(probePos(3))));
    % Probe Command
        fprintf(fileID,'%s\n',strcat("G38.2 Z-90 F",num2str(probeSpeed)));
    % Return to current X, Y, Home
        fprintf(fileID,'%s\n',strcat("G0 X",num2str(probePos(1)),...
            " Y",num2str(probePos(2)),...
            " Z",num2str(probePos(3))));
    end
    
    % make footer commands
    fprintf(fileID,'%s\n',"G0 Z0; (Retract)");
    fprintf(fileID,'%s\n',"G0 X0 Y0 Z0 A0 B0 C0; (Go to home)");
    fprintf(fileID,'%s\n',"M2; (Program Complete)");
    fclose(fileID);
    
end

