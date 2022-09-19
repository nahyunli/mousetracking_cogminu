function tmtray = OSclean(tmtray)
  
  norespIDX=[tmtray.taskType tmtray.n0 tmtray.n1 tmtray.n2]; 
  %norespIDX=cellfun(@str2num,norespIDX);
  norespIDX(:,5)=ones(size(norespIDX,1),1);
  
  for i2 = 1:size(norespIDX,1)-1
      if sum(norespIDX(i2,1:4)==norespIDX(i2+1,1:4))==4
         xPos1 = split(tmtray.xpos_get_response_pos(i2),["[","]",", "]);xPos1=str2double(xPos1(2:end-1));
         xPos2 = split(tmtray.xpos_get_response_pos(i2+1),["[","]",", "]);xPos2=str2double(xPos2(2:end-1));    
         if sum(xPos1-xPos2)==0
            norespIDX(i2,5)=0;
         end
         clear xPos1 xPos2
      end      
  end
  tmtray=tmtray(logical(norespIDX(:,5)),:);
end

