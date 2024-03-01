% For processing DelayLine Data this function assumes that the DUT spun
% twice.
function [daqData_out] = process_daq_data(daq,varargin)
    % Create the input parser
    p = inputParser;
    p.addRequired('daq',@isstruct);
    p.addOptional('dataType','Nonspecific', @(x)strcmpi(x,'Nonspecific') ...
        || strcmpi(x,'DelayLine')|| strcmpi(x,'DelayLineProdCham'));
    p.addParamValue('RotationRate',0, @(x)isnumeric(x) ); % Secs / Deg.
    
    p.parse( daq, varargin{:} );
    
    % FFT the Time Domain Data
    fftFact = 1;
    fftSize = 256 * fftFact;
    
    win = blackman(daq.up_samples,'periodic');
    daq.DATA = daq.data(1:daq.up_samples,:,:);
    daq.DATA = bsxfun(@times,daq.DATA,win);
    daq.DATA = fft(daq.DATA,fftSize,1)./sqrt(fftSize);
    % Throw away Conjugate
    daq.DATA = daq.DATA(1:(fftSize/2+1),:,:);
    
    % Convert to dB
    daq.DATA_dB = 20*log10(abs(daq.DATA));
    
    % Delay Line Data find pks and mode
    if strcmpi(p.Results.dataType,'DelayLine') || strcmpi(p.Results.dataType,'DelayLineProdCham')
        
        daq.peakSearchStartBin = 5;
        daq.peakSearchStartBin = daq.peakSearchStartBin * fftFact;
        daq.maxAcrossTime = max(daq.DATA_dB,[],3);
        % Find the Active Target Response
        [ ~, daq.pksBinIndx ] = max(daq.maxAcrossTime(daq.peakSearchStartBin:end,:),[],1);
        daq.pksBinIndx = daq.pksBinIndx + daq.peakSearchStartBin -1;
        
        % Do a sanity check - all of the maxBins should be equal to each other
        % sense the active target is at the same range in all of the channels.
        daq.targetResponseBin = mode(daq.pksBinIndx);
        workingChannels = daq.targetResponseBin == daq.pksBinIndx;
        if ~(all(workingChannels))
            fprintf('**** WARNING: All peaks not found in same range bin (not all channels are working)! ****\n');
        end
               
        % Assuming the DUT spun twice in the chamber.
        % Find each response
        daq.midSpinScanIndx = floor(size(daq.DATA,3)/2);
        
        [ ~, firstPeakTimeIndx ] = max( daq.DATA_dB(daq.targetResponseBin,:,1:daq.midSpinScanIndx),[],3);
        [ daq.pks_dB, secondPeakTimeIndx ] = max( daq.DATA_dB(daq.targetResponseBin,:,(daq.midSpinScanIndx+1):end),[],3);
        secondPeakTimeIndx = secondPeakTimeIndx + daq.midSpinScanIndx;
        
        % Only use the working channels to calculate the boresight
        % position.
        daq.boresightIndex = round(sum( workingChannels.*secondPeakTimeIndx)/sum(workingChannels));
        boresightIndex0 = round(sum( workingChannels.*firstPeakTimeIndx)/sum(workingChannels));
        if strcmpi(p.Results.dataType,'DelayLineProdCham')
            % The Production Chamber may have different rotation times.
            % Figure out the rotation speed by looking at how fast the
            % Channel peaks are sweeping.
            daq.time2deg = 1/360 * mean(diff( secondPeakTimeIndx )) * daq.scan2time * 68.7161; % Magic Number = mean(diff( secondPeakTimeIndx ))
            daq.scan2deg = daq.scan2time * daq.time2deg;
        else
            daq.scan2deg = 360./mean(secondPeakTimeIndx - firstPeakTimeIndx);
        end
        daq.x_axis_degree = daq.scan2deg*(-daq.boresightIndex:daq.scans-1-daq.boresightIndex);
        
        % Calculate Statistics
        daq.mean_pk = mean(daq.pks_dB);
        [daq.min_pk daq.min_pk_indx] = min(daq.pks_dB);
        [daq.max_pk daq.max_pk_indx] = max(daq.pks_dB);
        
        daq.channels_peak_indices = secondPeakTimeIndx;
        
        % Calculate Mode
        daq.mode = mode( round(daq.DATA_dB(daq.targetResponseBin,:,:)), 3 );
        % Calculate Max-to-Mode
        daq.mx2md = daq.max_pk - daq.mode;
        
        % Use the portion of the spin that the Sensor is pointed away from the horn
        % antenna to calculate the mean noise.
        daq.MeanAcrossTimeIndx0 = round((100/360)*(daq.boresightIndex - boresightIndex0))+boresightIndex0;
        daq.MeanAcrossTimeIndx1 = round((260/360)*(daq.boresightIndex - boresightIndex0))+boresightIndex0;
        
        daq.meanAcrossTime_dB = 10*log10(mean(abs(daq.DATA(:,:,daq.MeanAcrossTimeIndx0:daq.MeanAcrossTimeIndx1).^2),3));
        % Calculate Max-to-Mean
        daq.mx2mn = daq.pks_dB - daq.meanAcrossTime_dB(daq.targetResponseBin,:);
    end
    
    daqData_out = daq;
      
    
    
    
end