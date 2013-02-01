const RCMAX=254;

type rregioncreature = record
  crcsource:byte;
  hp,mp:byte;
  odds:byte;          {wander}
  recurring:boolean;  {wander}
  show:boolean;  {does creature show up?}
  used:boolean;  {is there a creature in this slot at all?}
  talk:byte;   {dialogue index}
  motive:byte; {stop, wait, roam, visit}
  anger:byte;  {angry at nobody, evil, animals, neutrals, good, player}
  obj,objdata:byte;  {footrest data}
  xchunk,ychunk:byte;
 end;
 rcrcarray = array[1..64] of rregioncreature; {was 64, so 190 more!}
 rcrcarray254 = array[0..0] of rregioncreature; {in fact 1..254, loaded as 4 blocks of 64, ignoring >254.}
(*
     For rooms, wandering creatures are simply decided upon room entry.

     For Wmaps, wandering creatures are decided with each call to
      getchunks.  If the creatures of that chunk are already in memory,
      nothing happens.  If it's a new chunk, the random calculations are
      made.
*)

var
    rcrc:^rcrcarray254;
    rcrcf:file of rcrcarray;

