classdef Phasor < handle
    % Describes methods and properties to draw a phasor
    %   Methods: 1. show/hide the outter-most circle
    %            2. show/hide x/y assymptote
    %            COMPLETEEEEE
    %   Properties:  - phi: inital angle by where the phasor will be moving
    %   from.
    %                - radius: circle radius
    %                - delta_phi: angular velocity step
    %                - center: array containing [x, y] center of the circle
    properties (SetAccess = public)
        center, radius, phi, delta_phi, color;
        showCirclePoint = true, circlePointColor = 'k', line_width = 1.5;
    end
    properties (SetAccess = private)
        circleHandle, circlePointHandle, ...
        assymptoteHandle;
    end
    
    events
       two_PI_lap_completed 
    end
    
    methods (Access = public)
        function obj = Phasor(center, radius, phi, color, delta_phi)
            % Constructor accepts 0 up to 5 arguments.
            if (nargin < 1 )
                obj.center = [0, 0];
                obj.radius = 1; 
                obj.phi = 0; % Default: 0 radians
                obj.delta_phi = 1/100;
                obj.color = 'k'; % Default: black
            elseif (nargin < 2)
                obj.center = center;
                obj.radius = 1; 
                obj.phi = 0; % Default: 0 radians
                obj.color = 'k'; % Default: black
                obj.delta_phi = 1/100;
            elseif (nargin < 3)
                obj.center = center;
                obj.radius = radius; 
                obj.phi = 0; % Default: 0 radians
                obj.color = 'k'; % Default: black
                obj.delta_phi = 1/100;
            elseif (nargin < 4)
                obj.center = center;
                obj.radius = radius; 
                obj.phi = phi;
                obj.color = 'k'; % Default: black
                obj.delta_phi = 1/100;
            elseif (nargin < 5)
                obj.center = center;
                obj.radius = radius; 
                obj.phi = phi;
                obj.color = color;
                obj.delta_phi = 1/100;
            else
                obj.center = center;
                obj.radius = radius;
                obj.phi = phi;
                obj.color = color;
                obj.delta_phi = delta_phi;
            end
        end
        
        function drawCircle(obj)
            % Draw the phasorCircle at [x, y] in the current axes. If there
            % is not, one will be created. The circle object will be
            % returned.
%             hold on;
            th = 0:pi/50:2*pi;
            % Generating the complete circle
            xunit = obj.radius * cos(th) + obj.center(1);
            yunit = obj.radius * sin(th) + obj.center(2);
            obj.circleHandle = plot(xunit, yunit, 'Color', obj.color, 'LineWidth', obj.line_width);
            % Checking if the circlePoint should be plotted
            if (obj.showCirclePoint)
               obj.circlePointHandle = plot(obj.radius * cos(obj.phi) + obj.center(1), ...
                                            obj.radius * sin(obj.phi) + obj.center(2), ...
                                            'Marker', 'o', ...
                                            'MarkerSize', obj.radius * 4,...
                                            'MarkerFaceColor', obj.circlePointColor, ...
                                            'MarkerEdgeColor', obj.circlePointColor);
            end
%             hold off;
        end
        
        function drawAssymptotes(obj, isVertical)
            limits = Phasor.setGetAssymptoteLimits();
            if (isVertical)
                obj.assymptoteHandle = line([obj.circlePointHandle.XData, obj.circlePointHandle.XData], limits(2, :), ...
                                                    'LineStyle', ':', ...
                                                    'Color', obj.color, ...
                                                    'LineWidth', obj.line_width);
            else
                
                obj.assymptoteHandle = line(limits(1, :), [obj.circlePointHandle.YData, obj.circlePointHandle.YData], ...
                                                      'LineStyle', ':', ...
                                                      'Color', obj.color, ...
                                                      'LineWidth', obj.line_width);
            end
            
        end
        
        function out = updateCirclePoint(obj)
            % Updates the current circlePoint position
            obj.phi = obj.phi + obj.delta_phi;
            point = [obj.radius * cos(obj.phi) + obj.center(1), obj.radius * sin(obj.phi) + obj.center(2)];
            obj.circlePointHandle.XData = point(1);
            obj.circlePointHandle.YData = point(2);
            if (obj.phi > 2*pi)
                notify(obj, 'two_PI_lap_completed');
            end
            out = point;
            
        end
        
        function updateAssymptotes(obj, isVertical)
            if (isVertical)
                obj.assymptoteHandle.XData = [obj.circlePointHandle.XData, obj.circlePointHandle.XData];
            else
                obj.assymptoteHandle.YData = [obj.circlePointHandle.YData, obj.circlePointHandle.YData];
            end
            
        end
        
        function toggleAssymptotes(obj)
            % Show/hide assymptotes
           if (strcmp(obj.assymptoteHandle.Visible, 'on'))
               obj.assymptoteHandle.Visible = 'off';
           else
               obj.assymptoteHandle.Visible = 'on';
           end
        end
    end
    
    methods (Static)
        function out = setGetAssymptoteLimits (xLim, yLim)
            % Set assymptote limits in order to properly trace them.
            persistent x_lim y_lim;
            if (nargin)
                x_lim = xLim;
                y_lim = yLim;
            end
            out = [x_lim; y_lim];
        end
    end
end

