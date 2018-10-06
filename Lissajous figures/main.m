% Design the axes to simulate the Lissajous Curve Table as shown in:
% https://youtu.be/4CbPksEl51Q. This version, the idea is to construct a
% 4x4 table.

clear; close all;


global keepAnimating handles;
keepAnimating = true;

%% PARAMETERS
circle_radius = 1;
init_phi = 0;
delta_phi = circle_radius / 100; % Determines the speed of animation
circles_offset = 0.3 * circle_radius;

%% INTERFACE
handles.f = figure;
handles.ax = axes('NextPlot', 'add', 'Visible', 'off');
colors = get(handles.ax, 'colororder'); % Getting default matlab plot colors
pbaspect([1 1 1]); % Keeping axes aspect ratio as square;

% Setting callback function
set(handles.f, 'KeyPressFcn', @callback_keyboard_binds);

%% DRAWING

% Drawing the first row and column of circles
x_pos = 3 * circle_radius;
y_pos = -3 * circle_radius;
for i = 1 : 4
   center_row = [x_pos, 0]; center_col = [0, y_pos];   
   % Add row circle
   p = Phasor(center_row, circle_radius, init_phi, ...
              colors(i, :), i * delta_phi);
   p.drawCircle();
   if (i == 1)
       % Special TAG for the first circle. Since it will be the slowest
       % one, as soon as it triggers the event that a 2*pi lap was done,
       % all plots will be reset.
       p.circleHandle.Tag = 'slowest_circle';
       % Adding callback to execute when the event is triggered.
       addlistener(p, 'two_PI_lap_completed', @reset_movingCircles_plot);
   end
   handles.fixedCircles.row(i) = p;
   % Add column circle
   p = Phasor(center_col, circle_radius, init_phi, ...
              colors(i, :), i * delta_phi);
   p.drawCircle();
   handles.fixedCircles.column(i) = p;
   % Update indexes
   y_pos = y_pos - (2 * circle_radius + circles_offset);
   x_pos = x_pos + 2 * circle_radius + circles_offset;
end

% Building plots for all combination of circles
for i = 1 : 4
    x_coord = handles.fixedCircles.row(i).circlePointHandle.XData;
    for j = 1 : 4
        y_coord = handles.fixedCircles.column(j).circlePointHandle.YData;
        handles.movingCircles(i, j) = plot(x_coord, y_coord, 'LineWidth', 1.5, ...
                                                             'Color', 'k');
        handles.movingCirclesCursor(i, j) = plot(x_coord, y_coord, 'Marker', 'o', ...
                                            'MarkerSize', circle_radius * 4, ...
                                            'MarkerEdgeColor', [0.9216, 0.2824, 0.2471], ...
                                            'MarkerFaceColor', [0.9216, 0.2824, 0.2471]);
    end 
end

% Setting assymptotes limits
Phasor.setGetAssymptoteLimits(handles.ax.XLim, handles.ax.YLim);
handles.ax.XLimMode = 'manual'; handles.ax.YLimMode = 'manual';

% Draw assymptotes
for i = 1 : 4
    handles.fixedCircles.row(i).drawAssymptotes(true);
    handles.fixedCircles.column(i).drawAssymptotes(false);
end

animate();

function animate()
    global handles keepAnimating;
    while(keepAnimating)
        % Update circle point, assymptotes and moving circles
        for i = 1 : 4
            point_row = handles.fixedCircles.row(i).updateCirclePoint(); % x-coord is useful
            handles.fixedCircles.column(i).updateCirclePoint(); % y-coord is useful
            handles.fixedCircles.row(i).updateAssymptotes(true);
            handles.fixedCircles.column(i).updateAssymptotes(false);
            for j = 1 : 4
                y_coord = handles.fixedCircles.column(j).circlePointHandle.YData;
                % Updating moving circles
                handles.movingCircles(i, j).XData = [handles.movingCircles(i, j).XData, point_row(1)];
                handles.movingCircles(i, j).YData = [handles.movingCircles(i, j).YData, y_coord];
                % Updating moving circles cursor
                handles.movingCirclesCursor(i, j).XData = point_row(1);
                handles.movingCirclesCursor(i, j).YData = y_coord;
            end
        end
        drawnow;
    end
end

function reset_movingCircles_plot(obj, ~)
    global handles;
    
    % Reset only the 'phi' of the objected whose event is listened
    obj.phi = 0;
    for i = 1 : 4
        for j = 1 : 4
            handles.movingCircles(i, j).XData = [];
            handles.movingCircles(i, j).YData = [];
        end
    end
end

function callback_keyboard_binds(~, event)
    global keepAnimating handles;

    switch event.Key
        case 'p' % pause/unpause animation
            keepAnimating = ~keepAnimating;
            animate();
        case 'a' % show/hide assymptotes
            for i = 1 : 4
               handles.fixedCircles.row(i).toggleAssymptotes();
               handles.fixedCircles.column(i).toggleAssymptotes();
            end
    end
    
end