function rgb = plotColor(n)
    colors = {
        [0 0 255]         %blue

        [255 0 0]         %red
        [0 255 0]         %green
        [0 255 255]       %cyan
        [255 0 255]       %magenta
        [0 0 0]           %black
        [96 0 154]        %Eggplant
        [167 0 82]        %maroon
        [127 107 255]     %Orchid
        [255 114 221]     %Carnation
        [255 0 148]       %Strawberry
        [255 144 0]       %tangerine
        [253  255 87]     %banana
        [194 255 91]      %honeydew
        [0 255 0]         %green
        [24 152 0]        %fern
        [0 255 97]        %Flora
        [60 213 255]      %sky
        [0 255 255]       %turquiose
        [255 255 0]       %yellow
              };
    numColors = size(colors,1);
    rgb = colors{mod(n-1, numColors)+1}./255;

end