procedure messager(xc,yc:byte;var d:byte);
 var f:file of shortmsgrec;
     filesz:word;
     i,i1:integer;
     oh:byte;
     ss:string[40];
           begin
            oh:=helpindex;helpindex:=49;
            assign(f,ADVNAME+SHORTMSGFILE);
            {$I-} reset(f); {$I+}
            if ioresult<>0 then
             begin
             load_shortmsgfile(1);
             reset(f);
             end;
            filesz:=filesize(f)-1;
             say(1,183,0,'TYPE THE MESSAGE# TO USE.          ');
            if d=0 then
             say(1,191,0,'HIT …† TO MAKE A NEW ONE. (Š:ABORT)') else
             say(1,191,0,'HIT …† TO EDIT THIS ONE.  (Š:ABORT)');
             say(xc,yc,0,'#');
             ss:=readlin(xc+2,yc,3,1);
             if ss=#27 then ss:='ESC';
             if ss<>'ESC' then
             begin
              if ss='' then
               begin
                if d=0 then
                begin
                i:=0;
                i1:=0;
                repeat
                 inc(i);
                 seek(f,i-1);
                 read(f,shortmsg);
                 if shortmsg.empty then i1:=i;
                until (i1<>0) or (i-1>=filesz);
                if i1=0 then i1:=i+1;
                if i1>255 then i1:=255;
               end else i1:=d;
               end else
               begin
                val(ss,i1,i);
                if (i1=0) and (i=0) then d:=0;
                if i<>0 then i1:=0;
                if i1-1>filesz+1 then i1:=0;
               end;
              if i1<>0 then
               begin
                say(xc,yc,0,'#'+strnum(i1)+'   ');
                say(1,183,0,'EDIT MESSAGE:  ESC:QUIT/SAVE       ');
                say(1,191,0,'ƒ„0-ƒ„6:SET COLOR,  ƒ„D:DELETE MSG.');
                 if i1-1<=filesz then
                  begin;seek(f,i1-1);read(f,shortmsg);end
                 else
                  begin;seek(f,i1-2);read(f,shortmsg);clear_shortmsg;end;
                i:=shortmessageedit(yc+8);
                if i<>0 then
                    begin
                      if i>0 then d:=i1 else d:=0;
                      if i1-1<=filesz then seek(f,i1-1);
                      write(f,shortmsg);
                    end;
               end;
             end;
              close(f);
              obj_blowupobj(wobj);
              obj_filldata(wobj);
              helpindex:=oh;
            end;


procedure longmessager(xc,yc:byte;var d:byte);
 var f:file of longmsgrec;
     filesz:word;
     oh:byte;
     i,i1:integer;
     ss:string[40];
           begin
            oh:=helpindex;helpindex:=49;
            assign(f,ADVNAME+LONGMSGFILE);
            {$I-} reset(f); {$I+}
            if ioresult<>0 then
             begin
             load_longmsgfile(1);
             reset(f);
             end;
            filesz:=filesize(f)-1;
             say(1,183,0,'TYPE THE MESSAGE# TO USE.          ');
            if d=0 then
             say(1,191,0,'HIT …† TO MAKE A NEW ONE. (Š:ABORT)') else
             say(1,191,0,'HIT …† TO EDIT THIS ONE.  (Š:ABORT)');
             say(xc,yc,0,'#');
             ss:=readlin(xc+2,yc,3,1);
             if ss=#27 then ss:='ESC';
             if ss<>'ESC' then
             begin
              if ss='' then
               begin
                if d=0 then
                begin
                i:=0;
                i1:=0;
                repeat
                 inc(i);
                 seek(f,i-1);
                 read(f,longmsg);
                 if longmsg.empty then i1:=i;
                until (i1<>0) or (i-1>=filesz);
                if i1=0 then i1:=i+1;
                if i1>255 then i1:=255;
               end else i1:=d;
               end else
               begin
                val(ss,i1,i);
                if (i1=0) and (i=0) then d:=0;
                if i<>0 then i1:=0;
                if i1-1>filesz+1 then i1:=0;
               end;

              if i1<>0 then
               begin
                clearscreen;
                say(69,21,4,'MSG');
                say(69,30,4,'#'+strnum(i1));
                say(1,182,0,'ƒ„C:CLEAR MSG,  ESC:QUIT/SAVE      ');
                say(1,190,0,'ƒ„0-ƒ„6:SET COLOR,  ƒ„D:DELETE MSG.');
                 if i1-1<=filesz then
                  begin;seek(f,i1-1);read(f,longmsg);end
                 else
                  begin;seek(f,i1-2);read(f,longmsg);clear_longmsg;end;
                i:=longmessageedit;
                if i<>0 then
                    begin
                      if i>0 then d:=i1 else d:=0;
                      if i1-1<=filesz then seek(f,i1-1);
                      write(f,longmsg);
                    end;
               end;
             end;
              close(f);
              obj_blowupobj(wobj);
              obj_filldata(wobj);
              helpindex:=oh;
            end;
