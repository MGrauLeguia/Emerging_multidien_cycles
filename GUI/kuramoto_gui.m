function kuramoto_gui
    % Create figure and UI controls
    fig = figure('Name', 'Kuramoto-Sakaguchi Model', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 900, 500]);

    ax1 = polaraxes('Parent', fig, 'Position', [0.05, 0.15, 0.35, 0.7]);
    ax2 = axes('Parent', fig, 'Position', [0.45, 0.6, 0.45, 0.3]); % Kuramoto order parameter plot
    ax3 = axes('Parent', fig, 'Position', [0.45, 0.15, 0.25, 0.3]); % Periodogram plot

    % Editable Text for parameters
    function createTextField(x, y, label, defaultVal)
        uicontrol('Style', 'text', 'Units', 'normalized', ...
                  'Position', [x, y, 0.2, 0.05], 'String', label);
        uicontrol('Style', 'edit', 'Units', 'normalized', ...
                  'Position', [x+0.16, y, 0.08, 0.05], ...
                  'String', num2str(defaultVal), 'Tag', [label, 'Edit']);
    end

    createTextField(0.75, 0.45, 'Phase Lag (alpha)', 1.42);
    createTextField(0.75, 0.35, 'Broadness (b)', 5);
    createTextField(0.75, 0.25, 'Zeitgeber Strength (epsilon)', 0);
    createTextField(0.75, 0.15, 'Coupling Reduction (p)', 0);

    % Start simulation button
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
              'Position', [0.75, 0.05, 0.1, 0.05], ...
              'String', 'Start', 'Callback', @startSimulation);

    % Parameters
    N = 50;
    theta = 2 * pi * rand(N, 1);
    omega = 2 * pi* ones(N, 1);
    dt = 0.05;
    PSI = 0;

    orderParamHistory = [];
    timeHistory = [];
    maxTime = 500;
    fs = 20;
    per = linspace(4, 70, 100);
    running = false;
    % Store previous parameters
    prev_alpha = NaN;
    prev_b = NaN;
    prev_epsilon = NaN;
    prev_p = NaN;
    function startSimulation(~, ~)
        running = true;
        t = 0;
        totalSteps = 5000;
        refreshRate = 8;
        pauseTime = 0.05;
        % Remove previous annotation if it exists
        delete(findall(fig, 'Type', 'annotation'));
        alpha = str2double(get(findobj('Tag', 'Phase Lag (alpha)Edit'), 'String'));
        b = round(str2double(get(findobj('Tag', 'Broadness (b)Edit'), 'String')));
        epsilon = str2double(get(findobj('Tag', 'Zeitgeber Strength (epsilon)Edit'), 'String'));
        p = str2double(get(findobj('Tag', 'Coupling Reduction (p)Edit'), 'String'));
         % Check if parameters have changed
        if alpha ~= prev_alpha || b ~= prev_b  || p ~= prev_p
            % Clear previous plots expect for epsilon
            cla(ax2); % Clear order parameter plot
            cla(ax3); % Clear periodogram plot
            
            % Reset history data
            orderParamHistory = [];
            timeHistory = [];
    
            % Update stored parameters
            prev_alpha = alpha;
            prev_b = b;
            prev_p = p;
            theta = 2 * pi * rand(N,1);

        end
        radii = 0.5 + 0.5 * rand(N,1);

        while running && isvalid(fig)
            Rectangularwindow = zeros(N,1);
            if b > 0
                Rectangularwindow(1:b+1) = 1;
                Rectangularwindow(N-b+1:N) = 1;
            end
            G = zeros(N, N);
            for i = 1:N
                G(i, :) = circshift(Rectangularwindow, i-1);
            end
           
            if b > 0
                G = G/2/b;
            else
                G = zeros(N, N);
            end
            G = G .* (rand(N) > p);
            for step = 1:totalSteps
                PSI = mod(2 * pi * t, 2 * pi);  % Keep PSI within [0, 2π]

                theta = rk4_step(theta, dt, omega, G, alpha, epsilon, PSI);
            
                meanVec = mean(exp(1i * theta));
                orderParam = abs(meanVec);
                t = t + dt;
                orderParamHistory = [orderParamHistory, orderParam];
                timeHistory = [timeHistory, t];

%                 if orderParam >= 0.999  % Stop if order parameter reaches 1 (or close)
%                     disp('Synchronization achieved! Stopping simulation.');
%                     running = false;
%                     % Display message in the figure
%                     annotation('textbox', [0.4, 0.8, 0.2, 0.1], 'String', 'Synchronization Achieved! Stoping Simulation', ...
%            'FontSize', 14, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
%            'BackgroundColor', 'yellow', 'HorizontalAlignment', 'center');
%                     break;
%                 end
                if mod(step, refreshRate) == 0
                    cla(ax1);
                    polarplot(ax1, theta, radii, 'o', 'MarkerFaceColor', [0.3, 0.3, 0.8]);
                    hold(ax1, 'on');
                    theta_mean = angle(meanVec);
                    r_mean = abs(meanVec);
                    polarplot(ax1, [0 theta_mean], [0 r_mean], 'r', 'LineWidth', 2);
                    polarplot(ax1, theta_mean, r_mean, 'ro', 'MarkerFaceColor', 'r');
                    title(ax1, 'Oscillator Phases')
                    hold(ax1, 'off');

                    plot(ax2, timeHistory, orderParamHistory, 'b', 'LineWidth', 1.5);
                    title(ax2, 'Kuramoto Order Parameter');
                    xlabel(ax2, 'Time (days)'); ylabel(ax2, 'R');
                    box('on')
                    grid(ax2, 'on');
                    drawnow;
                end
                pause(pauseTime);
            end
            offsetTime = 2000;
            [~, ~, Periodogram, ~] = WaveletTransform(orderParamHistory(offsetTime:end), fs, per);
            plot(ax3, per, Periodogram, 'r', 'LineWidth', 2);
            title(ax3, '\bf{Periodogram of Order Parameter}', 'FontSize', 12);
            xlabel(ax3, 'Period (days)', 'FontSize', 10);
            ylabel(ax3, 'Power', 'FontSize', 10);
            xlim(ax3, [4 70]);
            grid(ax3, 'on');
            running = false;
        end
    end

    function theta_new = rk4_step(theta, dt, omega, G, alpha, epsilon, PSI)
        k1 = dt * theta_derivative(theta, omega, G, alpha, epsilon, PSI);
        k2 = dt * theta_derivative(theta + 0.5 * k1, omega, G, alpha, epsilon, PSI);
        k3 = dt * theta_derivative(theta + 0.5 * k2, omega, G, alpha, epsilon, PSI);
        k4 = dt * theta_derivative(theta + k3, omega, G, alpha, epsilon, PSI);
        theta_new = theta + (k1 + 2 * k2 + 2 * k3 + k4) / 6;
        theta_new = mod(theta_new, 2*pi);

    end

    function dtheta = theta_derivative(theta, omega, G, alpha, epsilon, PSI)
        diffm = bsxfun(@minus, theta, theta');
        dtheta = omega - sum(+sin((diffm + alpha)) .* G, 2) - epsilon * sin(theta - PSI);
    end
end
