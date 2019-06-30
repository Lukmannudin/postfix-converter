program postfix;
uses crt;
type
    stack_pointer = ^stack;
    stack = Record
        info: string;
        prev,next: stack_pointer;
    end;
var 
    awal,akhir: stack_pointer;
    test:String;
    i:Integer;
//Tambah belakang
procedure push_stack(data:string;var awal,akhir:stack_pointer);
var
   baru:stack_pointer;
begin
     new(baru);
     baru^.info:=data;
     baru^.prev:=nil;
     baru^.next:=nil;
     if awal=nil then
     begin
          awal:=baru;
          akhir:=baru;
     end
     else
     begin
          akhir^.next:=baru;
          baru^.prev:=akhir;
          akhir:=baru;
     end;
end;

procedure pop_stack(var awal,akhir:stack_pointer);
var
   phapus:stack_pointer;
begin
     if awal=nil then
        // writeln('Penghapusan dibatalkan karena data kosong')
     else
     if awal=akhir then
     begin
          dispose(awal);
          awal:=nil;
          akhir:=nil;
     end
     else
     begin
          phapus:=akhir;
          akhir:=akhir^.prev;
          akhir^.next:=nil;
          dispose(phapus);
     end;
end;

procedure show_stack(awal:stack_pointer);
var
   bantu:stack_pointer;
begin
     if awal=nil then
        // writeln('Data kosong')
     else
     begin
          bantu:=awal;
          while bantu<>nil do
          begin
               write(bantu^.info,' ');
               bantu:=bantu^.next;
          end;
          writeln;
     end;
end;

function opr_rank(simbol:string):integer;
begin
    case simbol of
        '+': opr_rank := 1;
        '-': opr_rank := 1;
        '*': opr_rank := 2;
        '/': opr_rank := 2;
        '^': opr_rank := 3;
    else
        opr_rank := -1;
    end;    
end;//end opr_rank

procedure postfix(rumus:String);
var 
    i:integer;
    p:String;
begin
    
    //Initialize
    push_stack('(',awal,akhir);
    rumus := concat(rumus,')');

    p:='';
    for i:= 1 to Length(rumus) do
    begin
        if (opr_rank(rumus[i]) = -1) then
        begin
            case rumus[i] of 
                '(': push_stack(rumus[i],awal,akhir);
                ')': begin
                    while akhir^.info <> '(' do
                    begin
                      p := Concat(p,akhir^.info);
                      pop_stack(awal,akhir);
                    end;
                    pop_stack(awal,akhir);
                end;
            else
                p := Concat(p,rumus[i])
            end;    
        end  
        else
            if (opr_rank(rumus[i])<opr_rank(akhir^.info)) then
                begin
                p:= Concat(p,akhir^.info);
                pop_stack(awal,akhir);
                push_stack(rumus[i],awal,akhir);    
                end
            else
                push_stack(rumus[i],awal,akhir);
              
                
    gotoxy(10,10+i);WriteLn(rumus[i]);
    gotoxy(30,10+i);WriteLn('', p);
    gotoxy(50,10+i);show_stack(awal); WriteLn();
    end;//endfor
end;

begin
  awal := nil;
  akhir := nil;   
  postfix('A+(B*C-(D/E^F)*G)*H');  

  show_stack(awal);  
  readln;
end.