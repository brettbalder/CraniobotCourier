function pointGen(max_steps)
    % Objective:  This function probes the skull in a rectangle centered on 
    % the input coordinates (bregma) in the machine coordinate system.
    % A text file with gcode is then output which may then be sent to the Craniobot. 
    %
    % Variables:
    % max_steps     maximum allowable spacing (mm) between probed points
    
    %% Coordinate presets
    %Polishing
    %left side polish y
    %logo_coordinates = [[-3.5,-3.5,-3.5,-3.5,-3.5,-3.35,-3.35,-3.35,-3.35,-3.35,-3.2,-3.2,-3.2,-3.2,-3.2,-3.05,-3.05,-3.05,-3.05,-3.05,-2.9,-2.9,-2.9,-2.9,-2.9,-2.75,-2.75,-2.75,-2.75,-2.75,-2.6,-2.6,-2.6,-2.6,-2.6,-2.45,-2.45,-2.45,-2.45,-2.45,-2.3,-2.3,-2.3,-2.3,-2.3,-2.15,-2.15,-2.15,-2.15,-2.15,-2,-2,-2,-2,-2,-1.85,-1.85,-1.85,-1.85,-1.85,-1.7,-1.7,-1.7,-1.7,-1.7],
     %                   [-3.5,-3,-2.5,-2,-1.5,-1.5,-2,-2.5,-3,-3.5,-3.5,-3,-2.5,-2,-1.5,-1.5,-2,-2.5,-3,-3.5,-3.5,-3,-2.5,-2,-1.5,-1.5,-2,-2.5,-3,-3.5,-3.5,-3,-2.5,-2,-1.5,-1.5,-2,-2.5,-3,-3.5,-3.5,-3,-2.5,-2,-1.5,-1.5,-2,-2.5,-3,-3.5,-3.5,-3,-2.5,-2,-1.5,-1.5,-2,-2.5,-3,-3.5,-3.5,-3,-2.5,-2,-1.5]];

    %left side polish x
    %logo_coordinates = [[-3.5,-3.35,-3.2,-3.05,-2.9,-2.75,-2.6,-2.45,-2.3,-2.15,-2,-1.85,-1.7,-3.5,-3.35,-3.2,-3.05,-2.9,-2.75,-2.6,-2.45,-2.3,-2.15,-2,-1.85,-1.7,-3.5,-3.35,-3.2,-3.05,-2.9,-2.75,-2.6,-2.45,-2.3,-2.15,-2,-1.85,-1.7,-3.5,-3.35,-3.2,-3.05,-2.9,-2.75,-2.6,-2.45,-2.3,-2.15,-2,-1.85,-1.7,-3.5,-3.35,-3.2,-3.05,-2.9,-2.75,-2.6,-2.45,-2.3,-2.15,-2,-1.85,-1.7],
    %                    [-3.5,-3.5,-3.5,-3.5,-3.5,-3.5,-3.5,-3.5,-3.5,-3.5,-3.5,-3.5,-3.5,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-2.5,-2.5,-2.5,-2.5,-2.5,-2.5,-2.5,-2.5,-2.5,-2.5,-2.5,-2.5,-2.5,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1.5,-1.5,-1.5,-1.5,-1.5,-1.5,-1.5,-1.5,-1.5,-1.5,-1.5,-1.5,-1.5]];


    %Craniotomy shapes

    %right rectangle example 
    %logo_coordinates = [[1.1,2.6,2.6,1.1,1.1],
    %                    [2.5,2.5,-4,-4,2.5]];

    %cerebellum
    logo_coordinates = [[-4.5,-4,4,4.5],
                        [-7,-8,-8,-7]];
    
    %% Interpolate coordinates based on max_step
    max_step = 5;
    num_steps = length(logo_coordinates);
    interp = [];
    for x = 1:num_steps-1
        %Caculate distance between two steps. Do we need to interpolate?
        a = logo_coordinates(1,x+1)-logo_coordinates(1,x);
        b = logo_coordinates(2,x+1)-logo_coordinates(2,x);
        L = sqrt(a*a+b*b);
        if L > max_step
            num_interp = ceil(L/max_step);
            x_inc = a/num_interp;
            y_inc = b/num_interp;
            for m = 1:num_interp
                x_start = logo_coordinates(1,x);
                y_start = logo_coordinates(2,x);
                interp(1:2,end+1) = [x_start + (m-1)*x_inc; y_start + (m-1)*y_inc];
            end
        else
            interp(1:2,end+1) = logo_coordinates(1:2,x);
        end
    end
    % don't forget the last coordinate pair
    interp(1:2,end+1) = logo_coordinates(1:2,end);

    %% Produce gcode probing file
    % create .txt file to store path
    fileID = fopen('probePath.txt','w');
    
    % make header commands
    fprintf(fileID,'%s\n',strcat("N1 G90;",...
        " (set to absolute coordinates motion and work coordinate system)"));
    fprintf(fileID,'%s\n', "N2 G21; (set to millimeters)");
    fprintf(fileID,'%s\n', strcat("N3 G0 X",num2str(interp(1,1)),...
            " Y",num2str(interp(2,1))));
    
    % Loop through theta by 1 step
    ln = 3; % line number
    for i = 1:length(interp)
    % Move to current X, Y, probing point
        ln = ln+1;
        probePos = [interp(1,i),interp(2,i),0];
        fprintf(fileID,'%s\n', strcat("N",num2str(ln),...
            " G0 X",num2str(probePos(1)),...
            " Y",num2str(probePos(2)),...
            " Z",num2str(probePos(3))));
        ln = ln+1;
    % Probe Command
        fprintf(fileID,'%s\n',strcat("N",num2str(ln),...
            " G38.2 Z-10",...
            " F5"));
        ln = ln+1;
    % Return to current X, Y, Zoffset
        fprintf(fileID,'%s\n',strcat("N", num2str(ln),...
            " G0 X",num2str(probePos(1)),...
            " Y",num2str(probePos(2)),...
            " Z",num2str(probePos(3))));
    end
    
    % make footer commands
    fprintf(fileID,'%s\n',strcat("N", num2str(ln+1),...
        " M2; (Program Complete)"));
    fclose(fileID);
end

