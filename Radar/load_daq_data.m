% Load Daq Data from a Matrix or HD Sensor
function Daq = load_daq_data( FileName, varargin )
    
    %Create an Argument parser.
    p = inputParser;
    p.addRequired('FileName', @ischar );
    p.addOptional('DataShift', 0, @(x)validateattributes(x,{'numeric'}, {'scalar', 'integer', '>=', 0 } ) );
    p.addParamValue('KeepDownChirp', false, @(x)or(x == false, x == true));
    p.addParamValue('LoadDataOnly', false, @(x)or(x == false, x == true));
    % Parse the input arguments
    p.parse( FileName, varargin{:} );
        
    Daq.long_file_name = p.Results.FileName;

    % Read DAQ file into memory.
    load_daq_file();
    
    if( p.Results.LoadDataOnly )
        return;
    end
    
    % Set some constants.
    SAMPLES_PER_SEC = 1e6;
    NEGATIVE_FULL_SCALE = -32768;
    POSITIVE_FULL_SCALE =  32767;

    % Find the headers in the data.
    foundHeaders = false;
    
    % Check to see if this is Alepheus Rev. 2.0 Daq data.
    if ~foundHeaders
        HEADER = [ POSITIVE_FULL_SCALE, NEGATIVE_FULL_SCALE, POSITIVE_FULL_SCALE, NEGATIVE_FULL_SCALE ];
        headers = findstr( Daq.data, HEADER );
        if numel(headers) > 100
            % Found HD or Matrix header
            NUM_SAMPS_IN_HEADER = 4;
            Daq.sensor = 'AlpheusRev2';
            
            % Find the Frame Length.
            head_spacing = diff(headers);
            frame_D = mode(head_spacing);  % Set the length of a frame.

            bad_frames = find(head_spacing~=frame_D);
            if bad_frames > 0; error('AlpheusRev2 cannot support bad DAQ Data!!!'); end
            
            num_ch = 2;
            scan_D = frame_D;
            frame_D = frame_D/num_ch;
            scan_N = numel(head_spacing);
            
            Daq.data = Daq.data(headers(1):(headers(end)-1));
            Daq.data = reshape(Daq.data,num_ch,frame_D,scan_N);
            % Throw away the header.
            Daq.data = Daq.data(:,3:end,:);
           
            % Correct data shift error
            frame_D = frame_D - NUM_SAMPS_IN_HEADER/num_ch;
            scan_N = scan_N-1;
            if(dataShift ~= 0)
                dataShift = dataShift + frame_D-256;
            end
            Daq.data = Daq.data(:,(dataShift+1):(scan_N*frame_D+dataShift));
            Daq.data = reshape(Daq.data,num_ch,frame_D,scan_N);
            
            Daq.data = permute(Daq.data,[2 1 3]);
          
            % Make it simple
            
            up_samples = 256;
            dn_samples = frame_D -up_samples;
            
            if( ~p.Results.KeepDownChirp )
                % Throw away the down chirp.
                Daq.data = Daq.data(1:up_samples, :,:);
            end
            
            Daq.channels = num_ch;
            Daq.numChannels = num_ch;
            Daq.scans = scan_N;
            Daq.frame_len = frame_D -2;
            Daq.frames=scan_N*num_ch;
            Daq.scan_len = scan_D;
            Daq.up_samples = up_samples;
            Daq.dn_samples = dn_samples;
            Daq.f_sample_rate = SAMPLES_PER_SEC;
            return;
        end
    end
    
    % Check for HD or Matrix
    if ~foundHeaders
        HEADER = [ POSITIVE_FULL_SCALE, NEGATIVE_FULL_SCALE ];
        headers = findstr( Daq.data, HEADER );
        if numel(headers) > 100
            % Found HD or Matrix header
            NUM_SAMPS_IN_HEADER = 3;
            NUM_SAMPS_IN_FOOTER = 0;
            ANT_INDEX_LOCATION = 2; % 0 base
            Daq.sensor = 'HD_or_Matrix';
            foundHeaders = true;
        end
    end
    
    % Check for Alpheus Header
    if ~foundHeaders
        HEADER = [ NEGATIVE_FULL_SCALE, POSITIVE_FULL_SCALE ];
        headers = findstr( Daq.data, HEADER );
        if numel(headers) > 100
            % Found Alpheus Headers.
            NUM_SAMPS_IN_HEADER = 4;
            NUM_SAMPS_IN_FOOTER = 3;
            ANT_INDEX_LOCATION = 6; % 0 base
            Daq.sensor = 'Alpheus';
            foundHeaders = true;
        end
    end
    
    % If we did not find the appropriate header then stop execution.
    if ~foundHeaders
        error('Could not find valid headers in data!!!\n');
    end
    
    % Find the Frame Length.
    head_spacing = diff(headers);
    frame_D = mode(head_spacing);  % Set the length of a frame.
    
    bad_frames = find(head_spacing~=frame_D);
    if bad_frames > 0; fprintf('Data has %i bad frame!!!\n',numel(bad_frames)); end
    
    if strcmp(Daq.sensor,'AlpheusRev2')
        if bad_frames > 0
            error('AlpheusRev2 cannot support bad DAQ Data!!!');
        end
    end
    % Find the number of channels
    if ANT_INDEX_LOCATION < NUM_SAMPS_IN_HEADER
        AntIndx = ANT_INDEX_LOCATION;
    else
        AntIndx = frame_D - NUM_SAMPS_IN_HEADER - NUM_SAMPS_IN_FOOTER + ANT_INDEX_LOCATION;
    end
    
    % Find all the Channels in the Data. Don't use the last header incase
    % there is not a full chirps worth of data.
    chns = Daq.data(headers(1:(end-1))+AntIndx);
    if strcmp(Daq.sensor,'Alpheus')
        % Fix bit field of antenna
        chns = uint16(chns);
        chns = bitshift(chns,-1);
        chns = double(chns);
    end
    % Find the most common one, we do this because there may be errors in
    % the data.
    [chn_mode,chn_mode_Cnt] = mode(chns);
    % Find the number of channels.
    num_ch = mode( diff( findstr( chns, chn_mode ) ) );
    
    % Now that we know the number of channels, find which channels.
    possibleChannels = 0:15;
    % Historgram the channels
    chnH = histc( chns, possibleChannels);
    chnH = chnH/chn_mode_Cnt;
    % Use the channels that show up to a significant degree. Do this
    % incase there are errors in the data.
    channels = possibleChannels(chnH>0.9);

    head_scans = headers( findstr( chns, channels(1)));
    head_scan_spacing = diff(head_scans);
    
    scan_D = mode(head_scan_spacing);
    % Do a sanity check!
    if( scan_D ~= num_ch*frame_D); error('Unknown scan formating!!!\n'); end
    
    % Find all the scans that have the correct spacing.
    good_scans = find(head_scan_spacing==scan_D);
    
    % Create a relative index for the Antenna IDs
    channel_indx = (0:(num_ch-1))*frame_D + AntIndx;
    scan_N = 0;
    
    for i = 1:numel(good_scans)
        % Check to see if the Channels are correct in the current scan.
        index0 = head_scans(good_scans(i));
        chns = Daq.data(index0 + channel_indx);
        if strcmp(Daq.sensor,'Alpheus')
            % Fix bit field of antenna
            chns = uint16(chns);
            chns = bitshift(chns,-1);
            chns = double(chns);
        end
        if all(chns == channels)
            Daq.data( (i-1)*scan_D+(1:scan_D)) = Daq.data(head_scans(good_scans(i))+(0:(scan_D-1)));
            scan_N = scan_N + 1;
        else
            fprintf('Skipping bad scan!\n');
        end
    end
    
    % Any bad data should be at the end, so trucate it - throw away the bad data.
    Daq.data = Daq.data( 1:(scan_N*scan_D) );
    
    % Reshape data into frames
    Daq.data = reshape(Daq.data', [frame_D, num_ch, scan_N]);
    % Save the header data seprate from the ADC data.
    header_footer_indices = [1:NUM_SAMPS_IN_HEADER ((1-NUM_SAMPS_IN_FOOTER):0)+frame_D];
    Daq.header = Daq.data(header_footer_indices,:,:);
    % Remove the header data from the ADC data.
    data_indices = (NUM_SAMPS_IN_HEADER+1):(frame_D-NUM_SAMPS_IN_FOOTER);
    Daq.data = Daq.data(data_indices, :,:);
    % Now that the header is removed resize the frame length
    frame_D = size(Daq.data,1);
    
    % Determine the sensor type.
    %sensor_type = 'UNKNOWN';
    up_samples = 256;
    dn_samples = NaN;
    
    % Check to see if it is a HD
    if any( frame_D == [ 279 281 283 286 ] )
        %Daq.sensor = 'HD_or_Matrix';
        up_samples = 256;
        dn_samples = frame_D -up_samples;
        
        if( ~p.Results.KeepDownChirp )
            % Throw away down samples.
            Daq.data = Daq.data(1:up_samples, :,:);
        end
    end
    
    Daq.channels = channels;
    Daq.num_channels = num_ch;
    Daq.scans = scan_N;
    Daq.frame_len = frame_D;
    Daq.frames=scan_N*num_ch;
    Daq.scan_len = scan_D;
    Daq.up_samples = up_samples;
    Daq.dn_samples = dn_samples;
    Daq.f_sample_rate = SAMPLES_PER_SEC;
    Daq.scan2time = Daq.frame_len * Daq.num_channels/Daq.f_sample_rate;
    Daq.time2scan = Daq.scan2time^-1;
    Daq.TimeLength = scan_N*Daq.scan2time;
    
    function load_daq_file()
        fid = fopen(Daq.long_file_name,'r');
        if (fid == -1); 
            fprintf('Unable to open file: %s\n',Daq.long_file_name);
            error('Aborting!!!');
        end
        [Daq.data, ~] = fread(fid,[1, Inf],'int16');
        fclose(fid);
        [Daq.filePath,Daq.fileName,Daq.fileExt] = fileparts(Daq.long_file_name);
    end
end


