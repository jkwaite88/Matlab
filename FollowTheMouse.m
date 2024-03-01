% Kalman filter example for tracking mouse position

% Define the state space model
A = eye(2); % state transition matrix
C = eye(2); % observation matrix
Q = 0.1*eye(2); % process noise covariance matrix
R = 0.5*eye(2); % measurement noise covariance matrix
x_hat = [0; 0]; % initial estimate of the state
P = eye(2); % initial estimate of the error covariance matrix

% Initialize the figure and plot the initial state estimate
fig_handle = figure(1);

hold on
xlim([-100, 100])
ylim([-100, 100])
axis_handle = gca;
plot(x_hat(1), x_hat(2), 'ro')

% Loop to update the state estimate based on new measurements
numPointsToPlot = 20;
i = 1;
points = zeros(2,numPointsToPlot);
while true
    % Get the current mouse position
    [x_m, y_m] = getMousePosition(fig_handle, axis_handle);
    z = [x_m; y_m]; % observation vector
    
    % Predict the next state estimate and error covariance
    x_hat_minus = A*x_hat;
    P_minus = A*P*A' + Q;
    
    % Update the state estimate and error covariance
    K = P_minus*C'*pinv(C*P_minus*C' + R);
    x_hat = x_hat_minus + K*(z - C*x_hat_minus);
    P = (eye(2) - K*C)*P_minus;
    
    %record points
    points(:,i)= x_hat;
    i = i + 1;
    if i > numPointsToPlot
        i = 1;
    end

    % Plot the updated state estimate
    
   if 1
    plot(x_hat(1), x_hat(2), 'ro')
    xlim([-100, 100])
    ylim([-100, 100])
   else
  
    plot(points(1,:), points(2,:), 'ro')
    xlim([-100, 100])
    ylim([-100, 100])
   end
    drawnow
    %pause(0.01);
end



% Helper function to get mouse position relative to the figure
function [x_rel_axis, y_rel_axis] = getMousePosition(fig_handle, axis_handle)
    % Get the current mouse position in pixels
    pos_pixels = get(0, 'PointerLocation');

    % Get the position and limits of the figure and axis in pixels
    fig_pos_pixels = getpixelposition(fig_handle);
    ax_pos_pixels = getpixelposition(axis_handle);
    xlims_pixels = get(axis_handle, 'XLim') / diff(axis_handle.XLim) * ax_pos_pixels(3) + ax_pos_pixels(1) + ax_pos_pixels(3)/2 +fig_pos_pixels(1);
    ylims_pixels = get(axis_handle, 'YLim') / diff(axis_handle.YLim) * ax_pos_pixels(4) + ax_pos_pixels(2) + ax_pos_pixels(4)/2+fig_pos_pixels(2);
    x_pixels_per_axis = diff(xlims_pixels) / diff(axis_handle.XLim);
    y_pixels_per_axis = diff(ylims_pixels) / diff(axis_handle.YLim);
    
    axis_center_x_pixels = mean(xlims_pixels);
    axis_center_y_pixels = mean(ylims_pixels);

    % Calculate the mouse position relative to the figure
    x_rel_pixels = (pos_pixels(1) - axis_center_x_pixels);
    y_rel_pixels = (pos_pixels(2) - axis_center_y_pixels);
    x_rel_axis = x_rel_pixels / x_pixels_per_axis;
    y_rel_axis = y_rel_pixels / y_pixels_per_axis;
end
