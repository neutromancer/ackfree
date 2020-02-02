

type masterrec = RECORD
  Parmor:array[1..7] of byte;
  bumpsound,stepsound:byte;
  invisible:byte;invis_icon:byte;
  Copytype:byte;
  Password:string[8];
  PlayerIcon:byte;
  PLregion:byte;
  anim_speed:byte;
  PLxloc,PLyloc,PLxch,PLych:byte;
  PLvehicle:byte;
  PWeapReady:byte;
  PINV:array[2..254] of byte;
  PCASH:word;
  race:array[1..3] of string[16];
  HP,HPmax,MP,MPmax,Strength,
  Intelligence,WeapSkill,RWeapSkill,Icon:array[0..3] of byte;
  varA,varB,varC,varD:array[1..3] of byte;
  Playername:string[11];
  poison:byte;
  Titlepic:byte;
  Titlemsg:byte;
  Intropic:byte;
  Intromsg:byte;
  Intromacro:byte;
  Titlemacro:byte;
  extracommand:string[5];
  music:byte;
  extracommand1:byte;
  stepmacro:byte;
  viewdistance:byte;
  alignment:byte;
  variables:array[1..26] of byte;
  textcolors:array[0..6] of word;
  experience:word; level:byte;
  levelexp:array[2..10] of word;
  levelmacro:array[2..10] of byte;
  ackversion:byte;
  minviewdistance:byte;
  torchduration:word;
  showclock:byte;
  cheat:byte;

  hitsound,misssound:byte;

  extracommand3,extracommand4:byte;
  hourmacro:byte;
  splituse:byte;
  darkforeground:byte;

  criminal:byte;
  regen_hp:byte;
  regen_mp:byte;

  time_cycle:byte;  {1 on, 0 off}
  hour:byte;
  minute:byte;
  day_macro:byte;
  days,old_days:word;
  deathmacro:byte;

  qtile:array[1..12] of word;

  darkbackground:byte;

  fly,nomove_n,nomove_s,nomove_e,nomove_w,unused:boolean;

  variables2:array[1..26] of byte; {26}
  variables2hi:array[8..26] of byte; {19}
{  moreblankspace:string[18];
  evenmoreblankspace:string[25];}
  countarmor:array[1..7] of byte; {0=yes, 1=no}
  showmenu:byte;
  extracommand2:byte;
  variableshi:array[8..26] of byte;
 end;

type ittystring = string[5];
