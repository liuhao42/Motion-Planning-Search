function path = A_star_search(map,MAX_X,MAX_Y)
%%
%This part is about map/obstacle/and other settings
    %pre-process the grid map, add offset
    size_map = size(map,1);   %size_map为起点+终点+障碍物个数
    Y_offset = 0;
    X_offset = 0;
    
    %Define the 2D grid map array.
    %Obstacle=-1, Target = 0, Start=1
    MAP=2*(ones(MAX_X,MAX_Y));  %MAP为二维栅格地图，初始化每个栅格值为2
    
    %Initialize MAP with location of the target
    xval = floor(map(size_map, 1)) + X_offset;   %floor函数：朝负无穷大方向取整
    yval = floor(map(size_map, 2)) + Y_offset;
    xTarget = xval;
    yTarget = yval;
    MAP(xval,yval) = 0;
    
    %Initialize MAP with location of the obstacle
    for i = 2: size_map-1
        xval = floor(map(i, 1)) + X_offset;
        yval = floor(map(i, 2)) + Y_offset;
        MAP(xval,yval) = -1;
    end 
    
    %Initialize MAP with location of the start point
    xval = floor(map(1, 1)) + X_offset;
    yval = floor(map(1, 2)) + Y_offset;
    xStart = xval;
    yStart = yval;
    MAP(xval,yval) = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %LISTS USED FOR ALGORITHM
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %OPEN LIST STRUCTURE
    %--------------------------------------------------------------------------
    %IS ON LIST 1/0 |X val |Y val |Parent X val |Parent Y val |h(n) |g(n)|f(n)|
    %--------------------------------------------------------------------------
    OPEN=[];
    %CLOSED LIST STRUCTURE
    %--------------
    %X val | Y val |
    %--------------
    % CLOSED=zeros(MAX_VAL,2);
    CLOSED=[];
    %Put all obstacles on the Closed list
    k=1;%Dummy counter
    for i=1:MAX_X
        for j=1:MAX_Y
            if(MAP(i,j) == -1)
                CLOSED(k,1)=i;
                CLOSED(k,2)=j;
                k=k+1;
            end
        end
    end
    CLOSED_COUNT=size(CLOSED,1);
    %set the starting node as the first node
    xNode=xval;
    yNode=yval;
    OPEN_COUNT=1;
    goal_distance=distance(xNode,yNode,xTarget,yTarget);
    path_cost=0;
    % 将一个节点的信息插入到OPEN list队尾
    OPEN(OPEN_COUNT,:)=insert_open(xNode,yNode,xNode,yNode,goal_distance,path_cost,goal_distance);  %默认OPEN list中1/0为1，表示未被访问
    OPEN(OPEN_COUNT,1)=0;	%将起点标记为已访问
    CLOSED_COUNT=CLOSED_COUNT+1;
    CLOSED(CLOSED_COUNT,1)=xNode;   %将起点存入CLOSE list中
    CLOSED(CLOSED_COUNT,2)=yNode;
    NoPath=1;
    FinishSearch=0;
%%
%This part is your homework
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START ALGORITHM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while(~FinishSearch) %you have to dicide the Conditions for while loop exit 
        
        if(xNode == xTarget && yNode == yTarget)  % 找到目标节点，退出循环
            break
        end
        % expand_array(node_x,node_y,gn,xTarget,yTarget,CLOSED,MAX_X,MAX_Y);
        exp_array = expand_array(xNode,yNode,path_cost,xTarget,yTarget,CLOSED,MAX_X,MAX_Y);
        
        size_expand = size(exp_array,1);
        for i = 1:1:size_expand
            
            temp_x = exp_array(i,1);
            temp_y = exp_array(i,2);
            temp_h = exp_array(i,3);
            temp_g = exp_array(i,4);
            temp_f = exp_array(i,5);
            
            %查找当前要扩展的节点是否已经在OPEN list中,返回该节点的索引
            n_index = node_index(OPEN,temp_x,temp_y);
            
            
            if(n_index == OPEN_COUNT + 1)  % 当前要扩展的节点不在OPEN list中
                %path_cost = path_cost + temp_h;
                OPEN_COUNT = OPEN_COUNT + 1;
                % function new_row = insert_open(xval,yval,parent_xval,parent_yval,hn,gn,fn)
                OPEN(OPEN_COUNT,:) = insert_open(temp_x,temp_y,xNode,yNode,temp_h,temp_g,temp_f);
            else   %当前要扩展的节点已经存在于OPEN list中
                g_open = OPEN(n_index,7);
                if(g_open > temp_g)  %若到待扩展节点的新路径代价小于原来的路径,则把此节点的parent指向当前节点，并更新该节点的cost
                    OPEN(n_index,4) = xNode;
                    OPEN(n_index,5) = yNode;
                    %OPEN(n_index,6) = temp_h;  %h相同，不需要更新
                    OPEN(n_index,7) = temp_g;
                    OPEN(n_index,8) = temp_f;
                end
            end
        end
        
        %function i_min = min_fn(OPEN,OPEN_COUNT,xTarget,yTarget)
        minf_index = min_fn(OPEN,OPEN_COUNT,xTarget,yTarget);
        OPEN(minf_index,1)=0;     %将弹出的节点标记为已访问
        
        xNode = OPEN(minf_index,2);     %将弹出的节点作为下次迭代使用的节点
        yNode = OPEN(minf_index,3);
        path_cost = OPEN(minf_index,7);
        
        CLOSED_COUNT = CLOSED_COUNT + 1;
        CLOSED(CLOSED_COUNT,1) = xNode;   %将弹出的节点存入CLOSE list中
        CLOSED(CLOSED_COUNT,2) = yNode;
    
    end %End of While Loop
    
    %Once algorithm has run The optimal path is generated by starting of at the
    %last node(if it is the target node) and then identifying its parent node
    %until it reaches the start node.This is the optimal path
    % Store the optimal path
    
    path = [];
    count = 1;
    path_end_x = xNode;     %将Target节点存入path
    path_end_y = yNode;
    %从target节点开始依次地寻找当前节点的parent，直到找到start节点为止
    while(path_end_x ~= xStart || path_end_y ~= yStart)
        path(count,:)= [path_end_x,path_end_y];     %将当前点存入path中
        count = count + 1;
        current_index = node_index(OPEN,path_end_x,path_end_y);
        path_end_x = OPEN(current_index,4);     %找到当前节点的parent坐标
        path_end_y = OPEN(current_index,5);
    end 
    path(count,:) = [xStart,yStart];	%将Start节点存入path
    
   
end
