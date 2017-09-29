%=========================================================================
% cbxplot_format_fonts
%=========================================================================
% USAGE:
%  cbxplot_format_fonts( name, size )
%
% Set the font family and size for all the text in the current figure.
% See cbxplot-uguide.txt for more information.

function cbxplot_format_fonts( name, size )
  
  all_text = [ findall(gca,'type','text'); findall(gca,'type','axes') ];
  
  set( all_text, 'FontName', name );
  if ( nargin > 1 )
    set( all_text, 'FontUnits', 'points' );
    set( all_text, 'FontSize',  size     );
  end
