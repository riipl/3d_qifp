%=========================================================================
% cbxplot_format_margins
%=========================================================================
% USAGE:
%  cbxplot_format_margins( outer_margin )
%  cbxplot_format_margins( [ top, right, bottom, left ] )
%  cbxplot_format_margins( ..., inner_margin )
%  cbxplot_format_margins( ..., [ horizontal, vertical ] )
%
% Change the outer margins for all plots and optionally change the inner
% margins for plots with subplots. See cbxplot-uguide.txt for more
% information.

function cbxplot_format_margins( outer_margin, inner_margin )

  % Process outer margin argument
    
  if ( length(outer_margin) == 1 )
    outer_margin = [ outer_margin, outer_margin, ...
                     outer_margin, outer_margin ];
  end

  % Process inner margin argument
  
  if ( nargin == 1 )
    inner_margin = [ 0, 0 ];
  elseif ( length(inner_margin) == 1 )
    inner_margin = [ inner_margin, inner_margin ];
  end
    
  % We call the inner function twice so that we can do some
  % readjustment if changing the margins changes the inset
  
  cbxplot_format_margins_h( outer_margin, inner_margin );
  cbxplot_format_margins_h( outer_margin, inner_margin );
  
function cbxplot_format_margins_h( outer_margin, inner_margin )

  % Each subplot has a position box which is the plot box and a tight
  % inset which specifies the extra space around the position box which
  % contains the title, tick labels, and other extra text. Taking the
  % position box and adding the tight inset results in the tightest
  % bounding box which contains everything in the plot. To move a
  % subplot you specify where to put the position box.
  %
  % The outer left margin is the space between the left edge of the
  % figure and the subplot in the first column with the maximum left
  % inset. So we need to go through all the subplots in the first
  % column to find the maximum inset. Then we can reposition the
  % subplot's position box so that they stay lined up and there is
  % the correct outer left margin space. We need to do this four all
  % the outer margins, and something similar for the inner margins.
  % The inner margins are defined as being between the maximum insets
  % on both sides.

  % First we need to get handles to all of the subplots. We also need
  % to exclude handles to legends since we don't want to move those.
  
  all_handles = get( gcf, 'Children' );
  H = [];
  for i = 1:length(all_handles)
    if ( ~strcmp(get(all_handles(i),'Tag'),'legend') )
      H(length(H)+1) = all_handles(i);
    end
  end

  % Loop through subplots and find the maximum insets in each column
  % and each row for both sides of the subplots. Note that we don't
  % really know which row and column each subplot is in, but we can
  % figure it out by comparing the position boxes. 
   
  row_pos     = []; % For each row what is the y axis of position box
  col_pos     = []; % For each col what is the x axis of position box

  inset_row_t = []; % Maximum top inset for each row
  inset_row_b = []; % Maximum bottom inset for each row
  inset_col_l = []; % Maximum left inset for each column
  inset_col_r = []; % Maximum right inset for each column

  for i = 1:length(H)
    pos   = get(H(i),'Position');
    inset = get(H(i),'TightInset');

    % Find max top and bottom insets
    if ( sum(row_pos == pos(2)) )      
      if ( inset(2) > inset_row_b(row_pos == pos(2)) )
        inset_row_b(row_pos == pos(2)) = inset(2);
      end
      if ( inset(4) > inset_row_t(row_pos == pos(2)) )
        inset_row_t(row_pos == pos(2)) = inset(4);
      end
    else
      row_pos(length(row_pos)+1) = pos(2);
      inset_row_b(length(inset_row_b)+1) = inset(2);
      inset_row_t(length(inset_row_t)+1) = inset(4);
    end    
  
    % Find max left and right insets
    if ( sum(col_pos == pos(1)) )      
      if ( inset(1) > inset_col_l(col_pos == pos(1)) )
        inset_col_l(col_pos == pos(1)) = inset(1);
      end
      if ( inset(3) > inset_col_r(col_pos == pos(1)) )
        inset_col_r(col_pos == pos(1)) = inset(3);
      end
    else
      col_pos(length(col_pos)+1) = pos(1);
      inset_col_l(length(inset_col_l)+1) = inset(1);
      inset_col_r(length(inset_col_r)+1) = inset(3);
    end    
  
  end

  % Now we need to figure out the subplot index for each axes. To do that
  % we first sort the positions so that they are in left to right, top
  % to bottom order. Then we go through the handles and see where each
  % handle fits into the sorted positions. That tells us the subplot
  % location. Then we create hmap which maps subplot indices to the
  % actual subplot handle. We also create new sorted inset vectors which
  % have the same data as inset_row_t, inset_row_b, inset_col_l, and
  % inset_col_r except that they are indexed by the subplot indices.
  
  num_rows = length(row_pos);
  num_cols = length(col_pos);
  sorted_row_pos = sort(row_pos);
  sorted_col_pos = sort(col_pos);

  for i = 1:length(H) 
    pos = get(H(i),'Position');
    col_idx = find(sorted_col_pos == pos(1));
    row_idx = find(sorted_row_pos == pos(2));
    hmap(row_idx,col_idx) = H(i);
    sorted_inset_row_t(row_idx,col_idx) = inset_row_t(find(row_pos == pos(2)));
    sorted_inset_row_b(row_idx,col_idx) = inset_row_b(find(row_pos == pos(2)));
    sorted_inset_col_l(row_idx,col_idx) = inset_col_l(find(col_pos == pos(1)));
    sorted_inset_col_r(row_idx,col_idx) = inset_col_r(find(col_pos == pos(1)));
  end

  % Calculate the sum of margin+inset for each row and column

  sum_inset_row_t = sum(sorted_inset_row_t,1);
  sum_inset_row_b = sum(sorted_inset_row_b,1);
  sum_inset_row   = sum_inset_row_t + sum_inset_row_b;
  
  sum_inset_col_l = sum(sorted_inset_col_l,2);
  sum_inset_col_r = sum(sorted_inset_col_r,2);
  sum_inset_col   = sum_inset_col_l + sum_inset_col_r;

  % Calculate the target width and height of each subplot. This is
  % the width and height of the box in the grid not the width and
  % height of the position box or bounding box.

  width ...
   = ( 1 - sum_inset_col(1) - outer_margin(2) - outer_margin(4) ... 
         - inner_margin(1)*(num_cols-1) ) / num_cols;
  
  height ...
   = ( 1 - sum_inset_row(1) - outer_margin(1) - outer_margin(3) ... 
         - inner_margin(2)*(num_rows-1) ) / num_rows;
  
  % Finally, we are ready to set the margins. This involves moving
  % each plot's position box to the appropriate location (and
  % resizing the position box).
  
  curr_x = outer_margin(4);
  curr_y = outer_margin(3);
  for row_idx = 1:num_rows
    for col_idx = 1:num_cols
   
      h = hmap(row_idx,col_idx);
      if ( h == 0 )
        continue;
      end
      
      loc_x = curr_x + sorted_inset_col_l(row_idx,col_idx);
      loc_y = curr_y + sorted_inset_row_b(row_idx,col_idx);
      set( h, 'Position', [ loc_x, loc_y, width, height ] );

      curr_x = loc_x + width ...
               + sorted_inset_col_r(row_idx,col_idx) + inner_margin(1);
    
    end
    curr_x = outer_margin(4);
    curr_y = loc_y + height ...
             + sorted_inset_row_t(row_idx,1) + inner_margin(2);
  end
  
