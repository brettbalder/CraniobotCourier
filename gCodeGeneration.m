function [gCode] = gCodeGeneration(X,Y,Z,skullThickness,feedrate)
    % X,Y,Z is the probed position of each point
    if((numel(X) ~= numel(Y)) || (numel(X) ~= numel(Z)) || (numel(Y) ~= numel(Z)))
        gCode = "0"; % Whatever the 0 command is
        error('Something went wrong');
    else

        toolOffset = -16.9950; %-5.675 probe, -23.6 drillbit from arbitrary point
        Z = Z + toolOffset; % adjust for tooloffset
        
        depthPass = 0.1; % 1mm passess
        nProbedPoints = numel(X);
        nPasses = ceil(skullThickness/depthPass);
        numberPoints = 3*(nPasses * (nProbedPoints + 1) + 2); %(nProbedPoints + 1) because we want to make a full circle and end back at the starting point
        % + 2 because we want a "home" position, times 3 because 3
        % coordinates (x,y,z)

        home = [X(1),Y(1),0]; % 0,0,0? 
        
    % create .txt file to store path
    fileID = fopen('cuttingPath.txt','w');
    
    % make header commands
    fprintf(fileID,'%s\n', "G90; (set to absolute coordinates)");
    fprintf(fileID,'%s\n', "G21; (set to millimeters)");
    % Return to current X, Y, Home
    fprintf(fileID,'%s\n', strcat("G0 X",num2str(home(1)),...
      " Y",num2str(home(2)),...
      " Z",num2str(home(3))));
        % Loop through theta by 1 step
        for jj = 1:nPasses
            for ii = 1:nProbedPoints
                % Move to current X, Y, Home
                    fprintf(fileID,'%s\n', strcat("G1 X",num2str(X(ii)),...
                      " Y",num2str(Y(ii)),...
                      " Z",num2str(Z(ii)-jj*depthPass),...
                      " F",num2str(feedrate)));
                end
            % Go back to the starting point of the circle so we can
            % vertically mill down the next loop of ii
            fprintf(fileID,'%s\n', strcat("G1 X",num2str(X(1)),...
              " Y",num2str(Y(1)),...
              " Z",num2str(Z(1)-jj*depthPass),...
              " F",num2str(feedrate)));
        end
        % Return to current X, Y, Home
    fprintf(fileID,'%s\n', strcat("G0 X",num2str(home(1)),...
      " Y",num2str(home(2)),...
      " Z",num2str(home(3))));
    
    % make footer commands
    fprintf(fileID,'%s\n',"G0 Z0; (Retract)");
    fprintf(fileID,'%s\n',"G0 X0 Y0 Z0 A0 B0 C0; (Go to home)");
    fprintf(fileID,'%s\n',"M2; (Program Complete)");
    fclose(fileID);
end
