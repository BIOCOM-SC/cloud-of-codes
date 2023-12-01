function [plotcolorb,symb] = colorcountry(Country)

plotcolor = [228,26,28;
    55,126,184;
    77,175,74;
    152,78,163;
    255,127,0;
    225,205,51;
    166,86,40;
    247,129,191;
    153,153,153;
    166,206,227]./256;

if Country == "Austria"
    plotcolorb = plotcolor(1,:);
    symb = 'o';
elseif Country == "Belgium"
    plotcolorb = plotcolor(2,:);
    symb = 'o';
elseif Country == "Bulgaria"
    plotcolorb = plotcolor(3,:);
    symb = 'o';
elseif Country == "Croatia"
    plotcolorb = plotcolor(4,:);
    symb = 'o';
elseif Country == "Cyprus"
    plotcolorb = plotcolor(5,:);
    symb = 'o';
elseif Country == "Czechia"
    plotcolorb = plotcolor(6,:);
    symb = 'o';
elseif Country == "Denmark"
    plotcolorb = plotcolor(7,:);
    symb = 'o';
elseif Country == "Estonia"
    plotcolorb = plotcolor(8,:);
    symb = 'o';
elseif Country == "Finland"
    plotcolorb = plotcolor(9,:);
    symb = 'o';
elseif Country == "France"
    plotcolorb = plotcolor(10,:);
    symb = 'o';
elseif Country == "Germany"
        plotcolorb = plotcolor(1,:);
    symb = 'x';
elseif Country == "Greece"
    plotcolorb = plotcolor(2,:);
    symb = 'x';
elseif Country == "Hungary"
    plotcolorb = plotcolor(3,:);
    symb = 'x';
elseif Country == "Iceland"
    plotcolorb = plotcolor(4,:);
    symb = 'x';
elseif Country == "Ireland"
    plotcolorb = plotcolor(5,:);
    symb = 'x';
elseif Country == "Italy"
    plotcolorb = plotcolor(6,:);
    symb = 'x';
elseif Country == "Latvia"
    plotcolorb = plotcolor(7,:);
    symb = 'x';
elseif Country == "Lithuania"
    plotcolorb = plotcolor(8,:);
    symb = 'x';
elseif Country == "Luxembourg"
    plotcolorb = plotcolor(9,:);
    symb = 'x';
elseif Country == "Netherlands"
    plotcolorb = plotcolor(10,:);
    symb = 'x';
elseif Country == "Norway"
        plotcolorb = plotcolor(1,:);
    symb = 'square';
elseif Country == "Poland"
    plotcolorb = plotcolor(2,:);
    symb = 'square';
elseif Country == "Portugal"
    plotcolorb = plotcolor(3,:);
    symb = 'square';
elseif Country == "Romania"
    plotcolorb = plotcolor(4,:);
    symb = 'square';
elseif Country == "Slovakia"
    plotcolorb = plotcolor(5,:);
    symb = 'square';
elseif Country == "Slovenia"
    plotcolorb = plotcolor(6,:);
    symb = 'square';
elseif Country == "Spain"
    plotcolorb = plotcolor(7,:);
    symb = 'square';
elseif Country == "Sweden"
    plotcolorb = plotcolor(8,:);
    symb = 'square';
% elseif strcmpi(Country, 'Europe')
elseif Country == "Europe"
  plotcolorb = [0 0 0];
  symb = '^';
else
    disp("No match country")
end
end
