function [gCode] = millCircle(X,Y,Z,skullThickness,feedrate,tool,toolOffset)
    % Objective: The user enters the desired location for a circular plug to be
    % milled on a skull in stereotax coordinates. The thickness of the skull and
    % probe feedrate are also input. This function then probes the skull in a
    % circle centered on the input coordinates with a resolution of 36 points
    % (99.5% accurate to circumcircle area). A text file with gcode is then
    % output which may then be sent to the Craniobot.
    %
    % Variables:
    % X,Y,Z         Column vectors of probed x,y, and z coordinates of skull in
    %                   work coordinates
    % feedrate      Feedrate of mill (units/min)
    % tool          number of tool in tool table
    % toolOffset    Z-axis offset of tooltip from the machine origion
    depthPass = 0.1; % 1mm passess
    nProbedPoints = numel(X);
    nPasses = ceil(skullThickness/depthPass);
    % home is the position directly above the first probed point on the skull
    home = [X(1),Y(1),-toolOffset];  

    % create .txt file to store path
    fileID = fopen('millingPath.txt','w');

    % make header commands
    fprintf(fileID,'%s\n',strcat("N1 G90 G43 H",num2str(tool),...
        "; (set to absolute coordinates motion and work coordinate system)"));
    fprintf(fileID,'%s\n', "N2 G21; (set to millimeters)");
    fprintf(fileID,'%s\n', strcat("N3 G0 X",num2str(home(1)),...
      " Y",num2str(home(2)),...
      " Z",num2str(home(3))));
    
    % Loop through theta by one step
    ln = 3; %line number
    for jj = 1:nPasses
        % Loop through each probed point on skull
        for ii = 1:nProbedPoints
            ln = ln+1;
            % Move to current X, Y, Home
            fprintf(fileID,'%s\n', strcat("N", num2str(ln),...
              " G1 X",num2str(X(ii)),...
              " Y",num2str(Y(ii)),...
              " Z",num2str(Z(ii)-jj*depthPass),...
              " F",num2str(feedrate)));
        end
        % Go back to the starting point of the circle so we can
        % vertically mill down the next loop of ii
        ln = ln+1;
        fprintf(fileID,'%s\n', strcat("N", num2str(ln),...
          " G1 X",num2str(X(1)),...
          " Y",num2str(Y(1)),...
          " Z",num2str(Z(1)-jj*depthPass),...
          " F",num2str(feedrate)));
    end
    
    % Return to current X, Y, Home
    ln = ln+1;
    fprintf(fileID,'%s\n', strcat("N", num2str(ln),...
      " G0 X",num2str(home(1)),...
      " Y",num2str(home(2)),...
      " Z",num2str(home(3))));

    % make footer commands
    ln = ln+1;
    fprintf(fileID,'%s\n',strcat("N", num2str(ln),...
        " G0 Z",num2str(-toolOffset),"; (Retract)"));
    ln = ln+1;
    fprintf(fileID,'%s\n',strcat("N", num2str(ln),...
        " G0 X0 Y0 Z",num2str(-toolOffset)," A0 B0 C0; (Go to home)"));
    ln = ln+1;
    fprintf(fileID,'%s\n',strcat("N", num2str(ln)," M2; (Program Complete)"));
    fclose(fileID);
end
