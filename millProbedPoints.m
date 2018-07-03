function millProbedPoints(X,Y,Z,thickness,depth,feedrate)
    % Objective: After probing the skull, the user can generate a Gcode program for
    % milling the probed points.
    %
    % Variables:
    % X,Y,Z         Column vectors of probed x,y, and z coordinates of skull in
    %                   work coordinates
    % feedrate      Feedrate of mill (units/min)
    % thickenss     thickness of material
    % depth         depth per pass of mill

    nProbedPoints = numel(X);
    nPasses = ceil(thickness/depth);
    
    figure('Name','Surface Map');
    scatter3(X,Y,Z);
    axis equal
    xlabel('X-axis Location (mm)');
    ylabel('Y-axis Location (mm)');
    zlabel('Z-axis Location (mm)');
    title(sprintf('%d Total Points',nProbedPoints));
    
    % home is the position directly above the first probed point on the skull
    home = [X(1),Y(1),Z(1)+2];  

    % create .txt file to store path
    fileID = fopen('millingPath.txt','w');

    % make header commands
    fprintf(fileID,'%s\n',strcat("N1 G90; ",...
        "(set to absolute coordinates motion and work coordinate system)"));
    fprintf(fileID,'%s\n', "N2 G21; (set to millimeters)");
    fprintf(fileID,'%s\n', strcat("N3 G0 X",num2str(home(1)),...
      " Y",num2str(home(2)),...
      " Z",num2str(home(3))));
    
    % Loop through theta by one step
    ln = 3; %line number
    for j = 1:nPasses
        % Loop through each probed point on skulz
        for i = 1:nProbedPoints
            ln = ln+1;
            % Move to current X, Y, Home
            fprintf(fileID,'%s\n', strcat("N", num2str(ln),...
              " G1 X",num2str(X(i)),...
              " Y",num2str(Y(i)),...
              " Z",num2str(Z(i)-min(j*depth,thickness)),...
              " F",num2str(feedrate)));
        end
        % Go back to the starting point of the circle so we can
        % vertically mill down the next loop of ii
        ln = ln+1;
        fprintf(fileID,'%s\n', strcat("N", num2str(ln),...
          " G1 X",num2str(X(1)),...
          " Y",num2str(Y(1)),...
          " Z",num2str(Z(1)-min(j*depth,thickness)),...
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
        " G0 Z0; (Retract)"));
    ln = ln+1;
    fprintf(fileID,'%s\n',strcat("N", num2str(ln),...
        " G0 X0 Y0 Z0 A0 B0 C0; (Go to home)"));
    ln = ln+1;
    fprintf(fileID,'%s\n',strcat("N", num2str(ln)," M2; (Program Complete)"));
    fclose(fileID);
end
