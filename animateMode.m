function frames = animateMode(model, result, scale, modes)

% Number of animation frames 
nFrames = 360;

% Retrieve the base geometry data (undeformed)
[nodes,elements,T] = meshToPet(model.Mesh);
% Calculate the simulation timings. 
% Find the associated mode frequencies
omega = result.NaturalFrequencies;
% Use a time period that covers one period of the lowest frequency mode of
% interest.
timePeriod = 2*pi./omega(min(modes));
% Cover the time period in the required number of frames.
t = linspace(0,timePeriod,nFrames);
 
% Set up the figure
h = figure('units','normalized','outerposition',[0 0 1 1]);

% Handle each mode seperately
for m = 1:length(modes)
    modeID = modes(m);

    for n = 1:nFrames
        % The eigenvector represents the deformation from the static
        % solution for a particular eigenvalue
        
        % Construct the modal deformation and its displacement magnitude.
        modalDeformation = [result.ModeShapes.ux(:,modeID), ...
            result.ModeShapes.uy(:,modeID), ...
            result.ModeShapes.uz(:,modeID)]';
        modalDeformationMag = sqrt(sum(modalDeformation(:,:).^2,1));
        
        % Compute the location of the deformed mesh at the current
        % timestep
        nodesDeformed = nodes + ...
            scale.*modalDeformation*sin(omega(modeID).*t(n));
        
        % Plot the deformed mesh with magnitude of mesh as color plot.
        pdeplot3D(nodesDeformed,T,'ColorMapData', modalDeformationMag)
        
        % Add an annotation. The usual title(...) method gets crazy with
        % the rotating axes in 3D, so its easiest to use a uicontrol text
        % label which remains static. Looks a bit ugly though.
        uicontrol(h,'Style','Text','String',sprintf(['Mode %d, ', ...
            'Frequency = %g Hz\n',...
            'time (ms) = %.4f'], ...
            modeID,...
            omega(modeID)/(2*pi),...
            t(n)*1000.0 ),...
            'Units','Normalized','Position', [.4, .8,.2,.05],'FontSize',18)
        
        % Clean up the plots a bit
        colorbar off
        delete(findall(gca,'type','quiver'));
        qt = findall(gca,'type','text');
        set(qt(1:3),'Visible','off')
        axis equal
        
        % Set the camera and lighting
        camproj perspective
        camva(25)
        lighting gouraud
        [cx, cy,cz] = camPath(t(n), timePeriod);
        campos([cx, cy, cz])
        camtarget([0,0,0])

        % Finally, retrieve and store the frame
        frames(n) = getframe(h);
    end
    
    % Save the video
    saveVid(frames,sprintf('mode_%d.avi',modeID))
    
end
end

function [x, y, z] = camPath(t,timePeriod)
% Defines a camera path which circles the object once in a timePeriod,
% while oscillating above and below the object.
rotation = 2*pi;
x = .6*cos(rotation*t/timePeriod);
y = .6*sin(rotation*t/timePeriod);
z= 0.3*cos(2*pi*t/timePeriod)+0.1;
end

function saveVid( frames, title )
% Helper function which saves the video stored in frames.
v = VideoWriter(title);
open(v)
for frameNum = 1:length(frames)
    writeVideo(v,frames(frameNum))
end
close(v)
end
