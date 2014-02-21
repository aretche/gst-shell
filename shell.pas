    {Copyright (C) 2013-2014  Galante - Schab - Schab - Tommasi

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    Also add information on how to contact you by electronic and paper mail.}

program prueba;

uses MacroUtils,BaseUnix, Unix;
	
begin
  Writeln('GSTShell  Copyright (C) 2013-2014  Galante - Schab - Schab - Tommasi');
  Writeln('This program comes with ABSOLUTELY NO WARRANTY; for details type "show w".');
  Writeln('This is free software, and you are welcome to redistribute it');
  Writeln('under certain conditions; type "show c" for details.');
  Writeln();
  iniciarvariables;
  prompt;
  readln(Entrada);
  while Entrada<>'exit' do
    begin
      analizarEntrada(Entrada);
      if Lanzador(Descifrador(Entrada,' '))=0 then
        begin
	  pid := fpFork;
      	  case pid of
            -1 : Writeln('Error en el Sistema!!!');
             0 : begin        
	           lanzarExterno(Entrada);               
             	 end;
             else begin  
                    Waitprocess(pid);
		    recibirSalida;
                  end;
          end;
        end;
      analizarSalida(Entrada2);
    end;     
  Writeln('Hasta luego... ¡Gracias por usar nuestro shell!');
end.
