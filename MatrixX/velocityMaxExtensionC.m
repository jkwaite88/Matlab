classdef velocityMaxExtensionC <handle 
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties (GetAccess = public, SetAccess = private)
        colors
        f_sample
        t_sample
        N
        fft_size
        t
        f1
        f2
        s1_freq
        s2_freq
        s3_freq
        s1
        s1_real
        s2
        s2_real
        s3
        s3_real
        S1
        S1_single
        S1_real_single
        S2
        S2_single
        S2_real_single
        S3
        S3_single
        S3_real_single
        window_type
        window
        mag_time_figure_handle
        mag_time_axis_handle
        fig_name_mag_time ="MagTime";
        mag_time_window_axis_handle
        mag_freq1_figure_handle
        mag_freq1_axis_handle
        fig_name_freq1 ="Freq1";
        mag_freq2_figure_handle
        mag_freq2_axis_handle
        fig_name_freq2 ="Freq2";
        angle_figure_handle
        angle_imag_axis_handle
        angle_real_axis_handle
        angle_fig_name ="Angle";
    end
    properties (Constant)
        Hanning = 0;
        Hamming = 1;
    end

    methods
        %constructor
        function obj = velocityMaxExtensionC()
            obj.colors = colorC;
            set_N(obj,1024)
            set_f_sample(obj, 1e3);
            set_s_freq(obj, 100, 200, 500);
            set_window_type(obj, 'hann');
            find_existing_figures(obj);
        end
        %set methods
        function set_N(obj, N_in)
            obj.N = N_in;
            update_all_parameters(obj);
        end
        function set_fft_size(obj, fft_size_in)
            obj.fft_size = fft_size_in;
            update_all_parameters(obj);
        end
        function set_f_sample(obj, f_in)
            obj.f_sample = f_in;
            obj.t_sample = 1/obj.f_sample;
            update_all_parameters(obj);
        end
        function set_t_sample(obj, t_in)
            obj.t_sample = t_in;
            obj.f_sample = 1/obj.t_sample;
            update_all_parameters(obj);
        end
        function set_s_freq(obj, s1_freq_in, s2_freq_in, s3_freq_in)
            obj.s1_freq = s1_freq_in;
            obj.s2_freq = s2_freq_in;
            obj.s3_freq = s3_freq_in;
            update_all_parameters(obj);
        end
        function set_window_type(obj, type)
            type_num = 0;
            if ischar(type)
                type = lower(type);
                switch type
                    case strcmp(type, 'hann') | strcmp(type, 'hanning')
                        type_num = 0;
                    case strcmp(type, 'hamm') | strcmp(type, 'hamming')
                        type_num = 1;
                    otherwise
                        type_num = 0;
                end
            elseif isnumeric(type)
                type_num = type;
            else
                type_num = 0;
            end
            obj.window_type = type_num;
            update_all_parameters(obj);
        end
        %update parameter methods
        function update_f(obj)
            if ~isempty(obj.f_sample) && ~isempty(obj.N)
                obj.f1 = obj.f_sample*(0:(obj.N/2))/obj.N;
                obj.f2 = obj.f_sample*((-obj.N/2):1:(obj.N/2-1))/obj.N;
            end
        end
        function update_t(obj)
            if ~isempty(obj.t_sample) && ~isempty(obj.N)
                obj.t = (0:(obj.N-1))*obj.t_sample;
    
            end
        end
        function update_window(obj)
            if ~isempty(obj.window_type) && ~isempty(obj.N)
    
                switch obj.window_type
                    case 0
                        obj.window = hann(obj.N).';
                    case 1
                        obj.window = hamming(obj.N).';
                    otherwise
                        obj.window = hann(obj.N).';
                end
            end
        end
        function update_s(obj)
            if ~isempty(obj.s1_freq) && ~isempty(obj.t)
                obj.s1 = 1.0 * exp(1j*2*pi*obj.s1_freq*obj.t);
                obj.s1_real = real(obj.s1);
                obj.s2 = 1.0 * exp(1j*2*pi*obj.s2_freq*obj.t);
                obj.s2_real = real(obj.s2);
                obj.s3 = 1.0 * exp(1j*2*pi*obj.s3_freq*obj.t);
                obj.s3_real = real(obj.s3);
            end
        end
        function update_S(obj)
            if ~isempty(obj.s1) && ~isempty(obj.window)
                temp = fft(obj.s1 .* obj.window, obj.fft_size);
                obj.S1 = fftshift(temp);
                obj.S1_single = temp(1:(obj.N/2 + 1));
                temp = fft(obj.s1_real .* obj.window, obj.fft_size);
                obj.S1_real_single = temp(1:(obj.N/2 + 1));

                temp = fft(obj.s2 .* obj.window, obj.fft_size);
                obj.S2 = fftshift(temp);
                obj.S2_single = temp(1:(obj.N/2 + 1));
                temp = fft(obj.s2_real .* obj.window, obj.fft_size);
                obj.S2_real_single = temp(1:(obj.N/2 + 1));

                temp = fft(obj.s3 .* obj.window, obj.fft_size);
                obj.S3 = fftshift(temp);
                obj.S3_single = temp(1:(obj.N/2 + 1));
                temp = fft(obj.s3_real .* obj.window, obj.fft_size);
                obj.S3_real_single = temp(1:(obj.N/2 + 1));
            end
        end
        function update_all_parameters(obj)
            update_f(obj)
            update_t(obj)
            update_window(obj);
            update_s(obj);
            update_S(obj);
        end
        function update_figures(obj)
            plot_mag_time(obj)
            plot_mag_freq1(obj)
            plot_mag_freq2(obj)
            plot_angle(obj)
            positionFigures(obj)
        end
        %plot functions
        function positionFigures(obj)
            screenSize = get(0,'screensize');
            x1 = 0.05*screenSize(3);
            y1 = screenSize(4) - 0.05*screenSize(4) - obj.mag_time_figure_handle.OuterPosition(4);
            obj.mag_time_figure_handle.OuterPosition(1:2) = [x1 y1];

            x2 = obj.mag_time_figure_handle.OuterPosition(1) +obj.mag_time_figure_handle.OuterPosition(3) + 0.01*screenSize(3);
            obj.mag_freq1_figure_handle.OuterPosition(1:2) = [x2 y1];

            x3 = obj.mag_freq1_figure_handle.OuterPosition(1) +obj.mag_freq1_figure_handle.OuterPosition(3) + 0.01*screenSize(3);
            obj.mag_freq2_figure_handle.OuterPosition(1:2) = [x3 y1];

            y2 = y1 - 0.05*screenSize(4)  - obj.mag_time_figure_handle.OuterPosition(4);
            obj.angle_figure_handle.OuterPosition(1:2) = [x1 y2];


        end
        function find_existing_figures(obj)
            h = findobj('Type','figure');
            for i = 1:length(h)
                if strcmp(h(i).Name, obj.fig_name_mag_time)
                    obj.mag_time_figure_handle = h(i);
                    obj.mag_time_axis_handle = obj.mag_time_figure_handle.Children(2);
                    obj.mag_time_window_axis_handle = obj.mag_time_figure_handle.Children(1);
                    break;
                end
            end
            for i = 1:length(h)
                if strcmp(h(i).Name, obj.fig_name_freq1)
                    obj.mag_freq1_figure_handle = h(i);
                    obj.mag_freq1_axis_handle = obj.mag_freq1_figure_handle.Children(1);
                    break;
                end
            end
            for i = 1:length(h)
                if strcmp(h(i).Name, obj.fig_name_freq2)
                    obj.mag_freq2_figure_handle = h(i);
                    obj.mag_freq2_axis_handle = obj.mag_freq2_figure_handle.Children(1);
                    break;
                end
            end
            for i = 1:length(h)
                if strcmp(h(i).Name, obj.angle_fig_name)
                    obj.angle_figure_handle = h(i);
                    obj.angle_imag_axis_handle = obj.angle_figure_handle.Children(2);
                    obj.angle_real_axis_handle = obj.angle_figure_handle.Children(1);
                    break;
                end
            end
        end

        function plot_mag_time(obj)
            if isempty(obj.mag_time_figure_handle)
                obj.mag_time_figure_handle = figure;
                subplot(2,1,1)
                obj.mag_time_axis_handle = gca;
                subplot(2,1,2)
                obj.mag_time_window_axis_handle = gca;
            end
            obj.mag_time_figure_handle.Name = obj.fig_name_mag_time;
            figure(obj.mag_time_figure_handle.Number)
            plot(obj.mag_time_axis_handle, obj.t, real(obj.s1_real), 'Color', obj.colors.color01(1,:), 'LineWidth', 2, 'Marker', ".")
            hold(obj.mag_time_axis_handle, "on")
            hold(obj.mag_time_axis_handle, "off")
            plot(obj.mag_time_window_axis_handle, obj.t, real(obj.s1_real).*obj.window)
            xlabel(obj.mag_time_axis_handle, 'Time (seconds)')
            ylabel(obj.mag_time_axis_handle, 'Magnitude')
        end
        function plot_mag_freq1(obj)
            if isempty(obj.mag_freq1_figure_handle)
                obj.mag_freq1_figure_handle = figure;
                obj.mag_freq1_axis_handle = gca;
            end
            obj.mag_freq1_figure_handle.Name = obj.fig_name_freq1;
            figure(obj.mag_freq1_figure_handle.Number)
            plot(obj.mag_freq1_axis_handle, obj.f1, 20*log10(abs(obj.S1_real_single)), 'Color', obj.colors.color01(1,:), 'LineWidth', 2)
            hold(obj.mag_freq1_axis_handle,"on")
            plot(obj.mag_freq1_axis_handle, obj.f1, 20*log10(abs(obj.S2_real_single)), 'Color', obj.colors.color01(2,:), 'LineWidth', 1)
            plot(obj.mag_freq1_axis_handle, obj.f1, 20*log10(abs(obj.S3_real_single)), 'Color', obj.colors.color01(3,:), 'LineWidth', 0.1)
            hold(obj.mag_freq1_axis_handle,"off")
            title('FFT Magnitude, Single-Sided')
            xlabel(obj.mag_freq1_axis_handle, 'Frequency (Hz)')
            ylabel(obj.mag_freq1_axis_handle, 'Magnitude')
        end
        function plot_mag_freq2(obj)
            if isempty(obj.mag_freq2_figure_handle)
                obj.mag_freq2_figure_handle = figure;
                obj.mag_freq2_axis_handle = gca;
            end
            obj.mag_freq2_figure_handle.Name = obj.fig_name_freq2;
            figure(obj.mag_freq2_figure_handle.Number)
            plot(obj.mag_freq2_axis_handle, obj.f2, 20*log10(abs(obj.S1)), 'Color', obj.colors.color01(1,:), 'LineWidth', 2)
            hold(obj.mag_freq2_axis_handle,"on")
            plot(obj.mag_freq2_axis_handle, obj.f2, 20*log10(abs(obj.S2)), 'Color', obj.colors.color01(2,:), 'LineWidth', 1)
            plot(obj.mag_freq2_axis_handle, obj.f2, 20*log10(abs(obj.S3)), 'Color', obj.colors.color01(3,:), 'LineWidth', 0.5)
            hold(obj.mag_freq2_axis_handle,"off")
            title('FFT Magnitude, Double-Sided')
            xlabel(obj.mag_freq2_axis_handle, 'Frequency (Hz)')
            ylabel(obj.mag_freq2_axis_handle, 'Magnitude')
        end

        function plot_angle(obj)
            if isempty(obj.angle_figure_handle)
                obj.angle_figure_handle = figure;
                subplot(2,1,1)
                obj.angle_imag_axis_handle = gca;
                subplot(2,1,2)
                obj.angle_real_axis_handle = gca;
            end
            obj.angle_figure_handle.Name = obj.angle_fig_name;
            cla(obj.angle_imag_axis_handle)
            cla(obj.angle_real_axis_handle)
            plot(obj.angle_imag_axis_handle, obj.t, angle(obj.s1), 'Color', obj.colors.color01(1,:), 'LineWidth', 2)
            hold(obj.angle_imag_axis_handle,"on")
            plot(obj.angle_imag_axis_handle, obj.t, angle(obj.s2), 'Color', obj.colors.color01(2,:), 'LineWidth', 1)
            plot(obj.angle_imag_axis_handle, obj.t, angle(obj.s3), 'Color', obj.colors.color01(3,:), 'LineWidth', 0.5)
            hold(obj.angle_imag_axis_handle,"off")
            title('FFT Angle')
            xlabel(obj.angle_imag_axis_handle, 'time (seconds)')
            ylabel(obj.angle_imag_axis_handle, 'Angle - from complex signal')

            %plot(obj.angle_real_axis_handle, obj.t, ones(size(obj.t)), 'Color', obj.colors.color01(1,:), 'LineWidth', 2)
            plot(obj.angle_real_axis_handle, obj.t, angle(obj.s1_real), 'Color', obj.colors.color01(1,:), 'LineWidth', 2)
            hold(obj.angle_real_axis_handle,"on")
            plot(obj.angle_real_axis_handle, obj.t, angle(obj.s2_real), 'Color', obj.colors.color01(2,:), 'LineWidth', 1)
            plot(obj.angle_real_axis_handle, obj.t, angle(obj.s3_real), 'Color', obj.colors.color01(3,:), 'LineWidth', 0.5)
            hold(obj.angle_real_axis_handle,"off")
            title('FFT Angle')
            xlabel(obj.angle_imag_axis_handle, 'time (seconds)')
            ylabel(obj.angle_imag_axis_handle, 'Angle - from imag signal')
            xlabel(obj.angle_real_axis_handle, 'time (seconds)')
            ylabel(obj.angle_real_axis_handle, 'Angle - from real signal')
        end
        

    end
end