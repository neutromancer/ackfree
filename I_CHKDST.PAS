
function checkdest2(mapobj,creaturevehicle:byte):boolean;
 var spacepass,spacepassdata:byte; passable:boolean;
begin
  passable:=false;
  case mapobj of
   0:passable:=true; {empty space is always passable}
   255:passable:=false; {other creatures are always impassable}
   1..254:if obj^[mapobj].t>2 then passable:=false  {only spaces are passable}
     else
	   begin {analyze space}
	    spacepass:=obj^[mapobj].d[4]; spacepassdata:=obj^[mapobj].d[5];
        if creaturevehicle=255 then passable:=true else
		case spacepass of
		 23:passable:=true; {anything at all}
		 1,2:if creaturevehicle=0 then 
		     begin {creature has no vehicle, so this is a simple yes/no decision: }
			  if spacepass=1 then passable:=true else passable:=false;
			 end else
		     begin {creature has a vehicle, so we need to see how this will play out. }
			 
			    if obj^[creaturevehicle].t>5 then
			         begin {creature "vehicle" is an item, check for issues}
				      if spacepass=2 then
 				         begin {vehicle is required}
				          if creaturevehicle=spacepassdata 
						    then passable:=true; {does creature have the required item?}
						  if obj^[creaturevehicle].t=10 then 
						    if obj^[creaturevehicle].d[2]=spacepassdata 
						     then passable:=true; {does creature have a vehicle that counts as the required item?}
				         end else
				     begin {vehicle is not required}
					  passable:=true; {assume true unless the next condition ruins it}
					  if obj^[creaturevehicle].t=10 then
					   if obj^[creaturevehicle].d[3]>0 then
					    passable:=false; {creature has a vehicle, like a ship, that can only go where it is needed}
				     end;
			    end else
				
			    begin {creature "vehicle" is terrain, which overrides other settings and must match}
				 if creaturevehicle=mapobj then passable:=true;
			    end;
				
	         end; {vehicle check}

  		  else passable:=false; {else from case-statement, covering impassable or player-only conditions}	 
		 end; {case, space passable setting}
		 
	   end; {analyze space}
  end; {case, object number}
  checkdest2:=passable;
 end;

