{$O+}
unit U_keydis;

interface

uses dos;



  procedure freezekeyboard;
  procedure thawkeyboard;


implementation



var   NormalKeyboard : procedure;




  {}
  procedure DisableKeyboard;  interrupt;
  var port60, port61 : byte;
  begin
    port60 := Port[$60];  { KeyBoard controller data output buffer }
    port61 := Port[$61];  { Keyboard controller port B }
    Port[$61] := Port61 or $80;  { clear keyboard }
    Port[$61] := Port61;
    Port[$20] := $20;     { Programmable Intr. Contr. initialization }
  end;
  {}

  procedure freezekeyboard;
  begin
    GetIntVec ($09, @NormalKeyboard);
    SetIntVec ($09, @DisableKeyboard);
  end;

  procedure thawkeyboard;
  begin
    SetIntVec ($09, @NormalKeyboard);
  end;

begin

end.

