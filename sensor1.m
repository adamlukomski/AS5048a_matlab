%
% open a serial port, read data from it and plot it
%
% data format:
%   543054 2048
%   where 543054 is time (microseconds)
%   and 2048 is the value to be plotted
%
%

% open a serial port, on baudrate 115200, with a laaarge input buffer
mysensor = serial('/dev/ttyUSB0')
mysensor.BaudRate = 115200
mysensor.InputBufferSize = 2^15

% just to be sure, close and open it (crude fix)
fclose(mysensor)
fopen(mysensor)

% make a new plot
figure(1)
axis
hold on

% here all the read data will be kept for later processing
data_storage = [];

% you can use a finite loop here:
% for k=1:20000
while(1)
    % if there is some data waiting in the buffer
    if mysensor.BytesAvailable > 0
        % read all the available data as raw values
        rawdata = fread(mysensor, mysensor.BytesAvailable);
        % arduino sends it as text, so make a string out of it:
        % (by default the char(rawdata) is vertical, so transpose it)
        datatext = char(rawdata)';
        % the data can be broken, so find the first newline you can:
        for i=1:length(datatext)
            if double(datatext(i))==10
                i = i+1;
                break
            end
        end
        % and from the end do the same:
        for j=length(datatext):-1:1
            if double(datatext(j))==13
                j = j-1;
                break
            end
        end
        % now that the datatext(i:j) is a nice twocolumn text full of values we can simply
        % make a matrix out of it
        val = str2num( datatext(i:j) );
        % store it for later 
        data_storage = [ data_storage ; val(:,:) ];
        % plot - time, values
        plot( val(:,1), val(:,2),'.' )
        % sync the plot, you can use pause(0.01) if you want here
        drawnow
    end
end

% if the loop is a finite one:
% fclose(czujnik)
% if not, close the port after ctrl-c