function modulenum(n:byte):string;
 var s:String[4];
begin
 case n of
  1:s:='01';
  2:s:='02';
  3:s:='01';
  4:s:='04';
  5:s:='05';
  6:s:='05';
  7:s:='07';
  8:s:='08';
  9:s:='09';
  10:s:='10';
  11:s:='04';
 end;
 modulenum:='ACK'+s+'.EXE';
end;

