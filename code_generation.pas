program code_generation;

uses 
    sysutils, 
    postfix in 'lib/postfix.pas';

type
    stack_pointer = ^stack;
    stack = Record
        info: string;
        prev,next: stack_pointer;
    end;
    dataArray = array[0..100] of String; 
var
    data: dataArray;
    i,j:integer;
    temp:String;
    awal,akhir : stack_pointer;

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

    function findSomethingOnStack(findLabelPosition:String ;awal:stack_pointer):integer;
    var 
        bantu:stack_pointer;
        transversalPosition:integer;
        labelFind:String;
    begin
        transversalPosition := 0;
        if awal=nil then
            findSomethingOnStack := -1
        else
        begin
            bantu:=awal;
            while bantu<>nil do
            begin
                if bantu^.info = findLabelPosition then
                begin
                findSomethingOnStack := transversalPosition; 
                Break;
                end;
                Inc(transversalPosition);
                bantu:=bantu^.next;                  
            end;
            end;
    end;

    procedure show_stack(awal:stack_pointer);
    var
        bantu:stack_pointer;
    begin
        if awal=nil then
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

    procedure tambah_tengah(data:String;dataposisisisip:Integer;var awal,akhir:stack_pointer);
    var
        baru:stack_pointer;
        bantu:stack_pointer;
        currentTransversalPosition: integer;
    begin
        currentTransversalPosition := 0;
        if awal=nil then
            push_stack(data,awal,akhir)
        else
        begin
            bantu:=awal;
            while (currentTransversalPosition<>dataposisisisip)and
                    (bantu<>akhir) do
            begin
                Inc(currentTransversalPosition);
                bantu:=bantu^.next;
            end;
            if currentTransversalPosition=dataposisisisip then
            begin
                if bantu=awal then
                    push_stack(data,awal,akhir)
                else
                    bantu^.info := data;
            end
        end;
    end;

    procedure tambah_depan(data:String;var awal,akhir:stack_pointer);
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
            awal^.prev:=baru;
            baru^.next:=awal;
            awal:=baru;
        end;
    end;

    procedure aritmethicPostfix(data:dataArray;var awal:stack_pointer);
    var
        i,j,k : Integer;
        temp : String;
    begin
    temp := '';
    i:=0;
    j:=0;
        while i < Length(data) do
        begin
            if (data[i] = ':') AND (data[i] = '=') then
                begin
                  push_stack(':=',awal,akhir);
                  i := i+2;
                end
            else 
            if data[i] = 'IF' then
            begin
                  push_stack(data[i],awal,akhir);
                  i := i+1;
                  while data[i] <> 'THEN' do
                  begin
                    temp := Concat(temp,data[i]);
                    j := j+1;
                    inc(i);
                  end;
                  temp := postfix.postfix(temp);
                  for k := 1 to j do
                  begin
                    push_stack(temp[k],awal,akhir);
                  end;
                  j:=0;
                  temp:='';
                  
                  if data[i] = 'THEN' then
                    begin
                        push_stack(data[i],awal,akhir);
                        Inc(i);
                      while data[i] <> 'ELSE' do
                        begin
                            temp := Concat(temp,data[i]);
                            j := j+1;
                            inc(i);
                        end;
                    end;
                  temp := postfix.postfix(temp);
                  
                  for k := 1 to Length(temp) do
                  begin
                    push_stack(temp[k],awal,akhir);
                  end;
                  j:=0;
                  temp:='';
                  push_stack(data[i],awal,akhir);
            end
            else 
            if (data[i-1] = 'ELSE') OR (data[i]= 'ELSE')  then
                begin
                    push_stack(data[i],awal,akhir);
                    i := i+1; 
                    while data[i] <> ';' do
                    begin
                        temp := Concat(temp,data[i]);
                        j := j+1;
                        inc(i);
                    end;

                    temp := Concat(temp,data[i]);
                    temp := postfix.postfix(temp);

                    for k := 1 to Length(temp) do
                    begin
                        if temp[k] <> ';' then
                            push_stack(temp[k],awal,akhir);
                    end;
                    push_stack(';',awal,akhir);
                    j:=0;
                    temp:='';
                end
                else 
                    push_stack(data[i],awal,akhir);

            inc(i);
        end;
    end;

    procedure makeAssignmentRight(var awal:stack_pointer);
    var
        bantu:stack_pointer;
        dataMove: String;
    begin
    if awal=nil then
    else
        begin
            bantu:=awal;
            while bantu<>nil do
            begin
                if (bantu^.info = '=') AND(bantu^.next^.info = ':') then
                begin                    
                    dataMove := bantu^.next^.info;
                    bantu^.next^.info := bantu^.info;
                    bantu^.info := dataMove;
                end;
                bantu:=bantu^.next;
            end;
        end;
    end;

    procedure setNotationPostfix(awal:stack_pointer);
    begin
        tambah_tengah(
            IntToStr(findSomethingOnStack('BR',awal) + 2),
            findSomethingOnStack('label1',awal),
            awal,akhir
            );
        tambah_tengah(
            IntToStr(findSomethingOnStack(';',awal) + 1),
            findSomethingOnStack('label2',awal),
            awal,akhir
            );
    end;

    function code_generation(data:dataArray):stack_pointer;
    var
    i,j:integer;
    temp:String;
    begin
        awal := Nil;
        akhir := Nil;

        // data[0] := 'IF';
        // data[1] := 'a';
        // data[2] := '>';
        // data[3] := 'b';
        // data[4] := 'THEN';
        // data[5] := 'c';
        // data[6] := ':=';
        // data[7] := 'd';
        // data[8] := 'ELSE';
        // data[9] := 'c';
        // data[10] := ':=';
        // data[11] := 'e';
        // data[12] := ';';

        aritmethicPostfix(data,awal);
        makeAssignmentRight(awal);

            i:= 0;
            while (awal <> Nil) AND (i <20)  do
            begin
                writeln('DATA [',i,']',awal^.info);
                if (awal^.info = ':') AND (awal^.next^.info = '=') then
                begin
                data[i] := ':=';
                awal := awal^.next^.next;
                i:=i+1;
                end;
                

                data[i] := awal^.info;
                awal := awal^.next;
                i := i+1;
            end;
            

        awal := Nil;
        akhir := Nil;
        i := 0;
        temp := '';
        j:=0;
        while i < Length(data) do
            begin
            if (data[i] = 'IF') then
                begin
                while data[i] <> 'THEN' do
                    begin          
                        i:=i+1;
                        if data[i] <> 'THEN' then
                            begin
                                push_stack(data[i],awal,akhir);
                            end else if data[i] = 'THEN' then
                                begin
                                    push_stack('label1',awal,akhir);
                                    push_stack('BZ',awal,akhir);
                                end;
                    end;
                end
                else if data[i] = 'ELSE' then
                begin
                    push_stack('label2',awal,akhir);
                    push_stack('BR',awal,akhir); 
                end
                else 
                    push_stack(data[i],awal,akhir);
                inc(i);
            end;
            
            setNotationPostfix(awal);  

            code_generation := awal;
            // show_stack(awal);
    end;

begin

  code_generation(data);

  ReadLn;
end.