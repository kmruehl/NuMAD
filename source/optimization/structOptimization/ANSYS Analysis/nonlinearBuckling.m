%% Non-linear Buckling Analysis Script
function nonlinearLoadFactors=nonlinearBuckling(ansysFilename, ansys_path, ansys_product, config, ii, jj, ncpus)
    warning('output designvar. Currently does not work for nonlinear cases')

    script_name=strcat('commands3-',int2str(ii),'.mac');
    script_out=strcat('output3-',int2str(ii),'-',int2str(jj),'.txt');

    fid=fopen(script_name,'w+');
    fprintf(fid,strcat('!************   MODE-%i   ************\n'),ii);
    fprintf(fid,'/FILNAME,''%s'',1\n',ansysFilename);   %From master, change the jobname
    fprintf(fid,'resume\n');

    %Get Max displacement, UY
    fprintf(fid,'/POST1\n');
    fprintf(fid,'SET,1,%i\n',ii); %Read in results
    fprintf(fid,'nsel, all, node\n'); %Select all nodes
    fprintf(fid,'*get, Zncount, node,0,count\n'); %Find the number (quantity) of nodes selected
    fprintf(fid,'*dim,zNodeDisp,array,Zncount,1 \n'); %Allocate memory for an arry to hold nodal disp.

    %For each node populate array with Y-displacements
    fprintf(fid,'*DO, i,1,Zncount\n');    
    fprintf(fid,'*VGET, zNodeDisp(i,1), NODE, i, U, Y\n');
    fprintf(fid,'*ENDDO\n');

    %Find the min/max disp. value
    fprintf(fid,'*VSCFUN,zMaxUY,max,zNodeDisp\n'); 
    fprintf(fid,'*VSCFUN,zMinUY,min,zNodeDisp\n');

    fprintf(fid,'zImperfectionSF=%f/max(abs(zMaxUY),abs(zMinUY))\n',config.ansys.analysisFlags.imperfection(jj));

    %fprintf(fid,'zImperfectionSF=%f\n',config.ansys.analysisFlags.imperfection(jj));

    fprintf(fid,'/prep7\n');   
    fprintf(fid,'UPGEOM,zImperfectionSF,1,%i,''%s'',''rst''\n',ii,ansysFilename); %Introduce geometric imperfection from buckled mode shape-i                     

    fprintf(fid,'FINISH\n');  %Finish command requiered so that UPGEOM works after being in /PREP7
    filename=strcat(ansysFilename,'-',int2str(ii),'-',int2str(jj)); %The name of the next job name
    fprintf(fid,'/FILNAME,''%s'',1\n',filename);   %From master, change the jobname to master-1, master-2, etc...
    %fprintf(fid,strcat('SAVE,''',filename,''',''db'',''',strrep(pwd,'\','\\'),'''\n'));

    fprintf(fid,'\n');
    %Nonlinear Static Analysis
    fprintf(fid,'/solu\n');
    fprintf(fid,'antype,0\n');
    %fprintf(fid,'irlf,-1\n');
    fprintf(fid,'pstres,0\n');
    fprintf(fid,'NLGEOM,1\n');
    fprintf(fid,'TIME,%f\n',1);
    loadScaleFactor=5; %Make sure to scale the load arbitrarily high enought such that the solution never converges
    fprintf(fid,'allsel\n');
    fprintf(fid,'esel,s,type,,33\n'); %Select all follower elements
    fprintf(fid,'SFSCALE,PRES,%f\n',loadScaleFactor);
    fprintf(fid,'OUTRES,NSOL,ALL\n');
    fprintf(fid,'NROPT,UNSYM\n');
    fprintf(fid,'allsel\n');
    fprintf(fid,'solve\n');
    fprintf(fid,'FINISH\n');

    fprintf(fid,strcat('SAVE,''',filename,''',''db'',''',strrep(pwd,'\','\\'),'''\n'));
    fprintf(fid,'/EXIT,NOSAVE\n');

    fclose(fid);

    %%%%%% RUN ANSYS%%%%%%%
    ansys_call = sprintf('SET KMP_STACKSIZE=2048k & "%s" -b -p %s -I %s -o %s -np %s',ansys_path,ansys_product,script_name,script_out,int2str(ncpus))    % KMP_STACKSIZE is 512k by default. This is not enough therefore SET
    % KMP_STACKSIZE=2048k has been specifed. 2048k may not be enough for other
    % simulations. EC
    % 

    
    [status, cmdout] = system(ansys_call)  % the windows system call to run the above ansys command
    fprintf('%s: Nonlinear Mode-%s Analysis Finished\n',datestr(now),int2str(ii))
    

    data = readANSYSoutputs(strcat(filename,'.mntr'),10);
    a=size(data);
    nonlinearLoadFactors=data(a(1),7)*loadScaleFactor; %Extract the load level on the last iteration before nonconvergence
end